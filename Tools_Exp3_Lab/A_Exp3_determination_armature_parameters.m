ActPath = pwd;
%Pfade f�r tdms-Import
addpath([ActPath '\Import_tdms\v2p5'])
addpath([ActPath '\Import_tdms\v2p5\tdmsSubfunctions'])
%Pfad f�r Funktionen
addpath([ActPath '\Functions'])

%Pfad f�r Messdaten ausw�hlen
ui_data_path_on = 0;
if ui_data_path_on == 1
    data_path = uigetdir('../Data','Select directory containing measurement files');
else
    data_path = '../Data';
end
clear ui_data_path_on

%L�schen von *.tdms_index-Files falls vorhanden
cd(data_path)
Dateien = dir;
for i = 1:length(Dateien)
    if Dateien(i).isdir == 0
        [pathstr,name,ext] = fileparts(Dateien(i).name);
        if strmatch('.tdms_index',ext,'exact')
            delete(Dateien(i).name)
        end
    end
end
clear Dateien pathstr name ext
cd(ActPath)


%Auswertung der Ankerparameter
cd(data_path)
[filename_tdms,pathname_tdms] = uigetfile({'*.tdms'},'Select tdms-datafiles for determination of armature parameters','MultiSelect','on');
cd(ActPath)
if ~isnumeric(filename_tdms)
    if iscell(filename_tdms)
        for i = 1:length(filename_tdms)
            [Time,Voltage_EM_V,Current_EM_A,Rot_Speed_U_min,Drehzahl_U_min_TTL,Infos] = V3_Import_Messdaten_EM( pathname_tdms,filename_tdms{i});
            V3_GUI_Ankerparameter(Time,Voltage_EM_V,Current_EM_A,Rot_Speed_U_min,Infos)
        end
    else
        [Time,Voltage_EM_V,Current_EM_A,Rot_Speed_U_min,Drehzahl_U_min_TTL,Infos] = V3_Import_Messdaten_EM( pathname_tdms,filename_tdms);
        V3_GUI_Ankerparameter(Time,Voltage_EM_V,Current_EM_A,Rot_Speed_U_min,Infos)
    end
end

clear ActPath filename_tdms pathname_tdms Zeit Spannung_EM_V Strom_EM_A Drehzahl_U_min Drehzahl_U_min_TTL Infos i File Path data_path