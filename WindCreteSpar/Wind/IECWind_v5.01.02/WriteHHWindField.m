% Function: WriteHHWindField
% Writes wnd file for FAST
%
% -----------------------------
% Usage:
% -------------
% In PreProcessingVariation (FAST):
% 'Parameter.TurbSim.URef'                    16
% '[Disturbance.v_0.time, Disturbance.v_0.signals.values]' {'CalculateEOG(30,Parameter)'}
% 'Disturbance.delta_H.time'                  {'Disturbance.v_0.time;'}
% 'Disturbance.delta_H.signals.values'        {'Disturbance.v_0.signals.values*0'}
% 'Disturbance.delta_V.time'                  {'Disturbance.v_0.time'}
% 'Disturbance.delta_V.signals.values'        {'Disturbance.v_0.signals.values*0'}
% 'Disturbance.v_0L'                          {'Disturbance.v_0'}
% 'Disturbance.delta_VL'                      {'Disturbance.delta_V'}
% 'Disturbance.delta_HL'                      {'Disturbance.delta_H'}
% 'n'                                         {'length(Disturbance.v_0.signals.values)'}
% 'HHData'                                    {'[Disturbance.v_0.time,Disturbance.v_0.signals.values,zeros(n,2),Disturbance.delta_H.signals.values*126/13,zeros(n,1),Disturbance.delta_V.signals.values*126/13,zeros(n,1)]'}
% 'Parameter.TurbSim.WindFieldName'           {'[''Wind\EOG_'',num2str(Parameter.TurbSim.URef,''%02i''), ''.wnd'']'}
% 'dummy'                                     {'WriteHHWindField(HHData,[Parameter.TurbSim.WindFieldName]);'}     
% 'Parameter.FASTInputModifications{2}{1,1}'  {'[''..\'',Parameter.TurbSim.WindFieldName]'}

% 
% ------------
% Input:
% -------------
% -
% ------------
% Output:
% ------------
% 
% ------------
% Needs:
% ------------
%
% ------------
% Modified:
% -------------
% Doku FS 31.1.15

% ------------
% ToDo:
% -------------

% -----------
% Created: 
% David Schlipf  on 1.1.1999
% (c) Universitaet Stuttgart 
% ----------------------------------

function result = WriteHHWindField(HHData,pathData)

fid = fopen(pathData,'w+');

[rows,cols]=size(HHData);

fprintf(fid,[repmat('%6.3f ',1,cols), '\n'],(HHData'));

fclose(fid);

result = 1;