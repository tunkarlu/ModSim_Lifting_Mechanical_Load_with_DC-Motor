ActPath = pwd;
%Pfade für tdms-Import
addpath([ActPath '\Import_tdms\v2p5'])
addpath([ActPath '\Import_tdms\v2p5\tdmsSubfunctions'])
%Pfad für Funktionen
addpath([ActPath '\Functions'])

%Pfade für xlswriteauf Mac
addpath('C:\MATLAB\externeFunktionen\xlwrite')
addpath('C:\MATLAB\externeFunktionen')

cd ../Data
[filename_tdms,pathname_tdms] = uigetfile({'*.tdms'},'TDMS-Messdatenfile auswählen');
cd(ActPath)
if ~isnumeric(filename_tdms)
    [Zeit,Spannung_EM_V,Strom_EM_A,Drehzahl_U_min,Drehzahl_U_min_TTL,Infos] = V3_Import_Messdaten_EM( pathname_tdms,filename_tdms);

    % Construct a questdlg with three options
    s = ['What kind of evaluation should be performed with the file ' filename_tdms ' ?'];
    Auswahl = questdlg(s, 'Selection', ...
        'armature parameters','machine constant / friction','armature parameters');
    % Handle response
    switch Auswahl
        case 'armature parameters'
            V3_GUI_Ankerparameter(Zeit,Spannung_EM_V,Strom_EM_A,Drehzahl_U_min,Infos)
        case 'machine constant / friction'
            V3_GUI_Maschinenkonstante(Zeit,Spannung_EM_V,Strom_EM_A,Drehzahl_U_min,Infos)
    end

    clear Infos s Auswahl StatusMessung
end

clear filename_tdms pathname_tdms ActPath Zeit Spannung_EM_V Strom_EM_A Drehzahl_U_min Drehzahl_U_min_TTL

