function main()

ActPath = pwd;
addpath([ActPath '\Import_tdms\v2p5'])
addpath([ActPath '\Import_tdms\v2p5\tdmsSubfunctions'])

%cd Daten

% [filename_param,pathname_param] = uigetfile({'*.m'},'Parameterfile ausw�hlen');
% if ~isnumeric(filename_param)
%     run(fullfile(pathname_param,filename_param))
% end

[filename_tdms,pathname_tdms] = uigetfile({'*.tdms'},'Select tdms-datafile');
if ~isnumeric(filename_tdms)
    %Messdaten importieren und Variablen f�r Simulation belegen
    [Time,Voltage_EM_V,Current_EM_A,Rot_Speed_rpm,Rot_Speed_rpm_TTL,Infos] = V3_Import_Messdaten_EM( pathname_tdms,filename_tdms );
    
    assignin('base','time',Time');
    assignin('base','U_S',Voltage_EM_V');
    assignin('base','i_A',Current_EM_A');
    assignin('base','n_P',Rot_Speed_rpm_TTL');
    
    clear Voltage_EM_V Current_EM_A Rot_Speed_rpm Rot_Speed_rpm_TTL Infos
end

clear filename_param pathname_param filename_tdms pathname_tdms ActPath

end

function [Zeit,Spannung_EM_V,Strom_EM_A,Drehzahl_U_min,Drehzahl_U_min_TTL,Infos] = V3_Import_Messdaten_EM( pathname_tdms,filename_tdms)

    [Data,Infos] = TDMS_getStruct(fullfile(pathname_tdms,filename_tdms));

    %Extraktion Messkan�le
    ClusterNamen = fields(Data);
    Index = strfind(ClusterNamen,'Cluster');

    Zaehler = 0;

    for i = 1:length(Index)
        if Index{i} == 1
            eval(['DatenNamen = fields(Data.'  ClusterNamen{i} ');'])
            for j = 1:length(DatenNamen)
                if ((strcmp(DatenNamen(j),'name') == 0) && (strcmp(DatenNamen(j),'Props') == 0))
                    eval([DatenNamen{j} ' = Data.' ClusterNamen{i} '.' DatenNamen{j} '.data;'])
                    if Zaehler == 0
                        eval(['DatenLaenge = length(Data.' ClusterNamen{i} '.' DatenNamen{j} '.data);'])
                        Zaehler = 1;
                    end
                end
            end
        end
    end

    %Korrektur Zeitvektor (L�sung des Problems Timer-�berlauf)
    Indizes = find(diff(Zeit)<0);
    if ~isempty(Indizes)
        for i = 1:length(Indizes)
           Zeit(Indizes(i)+1:end) = Zeit(Indizes(i)+1:end)+Zeit(Indizes(i));
        end
    end
    clear Indizes

    Zeit = Zeit-Zeit(1);

    clear Data ClusterNamen Index Zaehler i j DatenLaenge DatenNamen


    %tempor�re Invertierung der Signale f�r Spannung und Strom
    %Spannung_EM__V_ = -Spannung_EM__V_;
    %Strom_EM__A_ = -Strom_EM__A_;

    %Auswertung Drehzahl aus TTL_Signal
    Faktor = 1;
    Indizes_st_Flanken = find(diff(TTL_norm__HI_LO_) == 1);
    st_Flanken = zeros(1,length(TTL_norm__HI_LO_));
    st_Flanken(Indizes_st_Flanken) = 1;
    Indizes_st_Flanken = Indizes_st_Flanken(1:Faktor:end);
    delta_t = diff(Zeit(Indizes_st_Flanken));
    omega = (Faktor*0.1*pi/180)./delta_t;
    n = 60*omega/2/pi;
    Drehzahl__U_min_ = zeros(1,length(Zeit));
    Drehzahl__U_min_(1:Indizes_st_Flanken) = 0;
    for i = 1:length(n)-1
        if delta_t(i) > 0.1         %wenn 100 ms keine Flanke kommt, wird auf Stillstand erkannt
            Drehzahl__U_min_(Indizes_st_Flanken(i):Indizes_st_Flanken(i+1)-1) = 0;
        else
            Drehzahl__U_min_(Indizes_st_Flanken(i):Indizes_st_Flanken(i+1)-1) = n(i);
        end
    end
    n_Vorzeichen = sign(Spannung_EM__V_);
    %Festlegung der R�ckgabegr��en 
    Drehzahl_U_min_TTL = Drehzahl__U_min_.*n_Vorzeichen;
    Drehzahl_U_min = Drehzahl__1_min_.*n_Vorzeichen;
    Spannung_EM_V = Spannung_EM__V_;
    Strom_EM_A = Strom_EM__A_;
    
    clear Faktor Indizes_st_Flanken st_Flanken delta_t omega n n_Vorzeichen

end

