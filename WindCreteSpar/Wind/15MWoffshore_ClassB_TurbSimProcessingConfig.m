function varargout = TurbSimProcessingConfig(iProcess, Purpose,varargin)

ProcessNameCell         = {
    '15MWoffshore_ClassB' {'EWM' [10.8]}
    };      
%----------------------------------------------------------------------------%
nProcess                = size(ProcessNameCell, 1);
ProcessName             = ProcessNameCell{iProcess, 1};
PreProcessingVariation  = ProcessNameCell{iProcess, 2};
%----------------------------------------------------------------------------%
% Directories
ProcessingDir           = ['..\Turbulence15MWoffshore\Wind\',ProcessName,'\'];
ResultsFilesDir         = ['..\Turbulence15MWoffshore\Wind\',ProcessName,'\'];
switch Purpose
    case 'PreProcessing'
        Variation       = varargin{1};
end
%----------------------------------------------------------------------------%
switch ProcessName 
    case {'15MWoffshore_ClassB'} 
        switch Purpose
            case 'PreProcessing'
             
                % Turbine
                Parameter.Turbine.HubHeight        	= 149.168; % [m] hub height from ED.sum file
                Parameter.Turbine.RotorDiameter     = 240; % [m] rotor diameter
                Parameter.Turbine.R                 = Parameter.Turbine.RotorDiameter/2;
                
                % TurbSim
                URef                                = Variation(1);
%                 RandSeed                            = Variation(2);
                Parameter.TurbSim.URef              = URef;
                b                                   = 5.6;
                I_ref                               = 0.14; %class B
                Parameter.TurbSim.IECturbc          = 'B';%I_ref*(0.75*URef+b)/URef*100;
                Parameter.TurbSim.RandSeed          = URef;
                Parameter.TurbSim.IEC_WindType      = '1EWM50';
                Parameter.TurbSim.IECstandard      = '1-ED3';
                Parameter.TurbSim.GridWidth         = 250;   % [m]
                Parameter.TurbSim.GridHeight        = 250;   % [m]
                Resolution                          = 12;    % [m]
                Parameter.TurbSim.NumGrid_Y      	= Parameter.TurbSim.GridWidth /Resolution+1;    % [-]
                Parameter.TurbSim.NumGrid_Z         = Parameter.TurbSim.GridHeight/Resolution+1;    % [-]
                Parameter.TurbSim.TimeStep          = 0.25;  % [s]
                Parameter.TurbSim.AnalysisTime    	= 3900; % [s]
                Parameter.TurbSim.UsableTime      	= 3600; % [s]
                Parameter.TurbSim.HubHt             = Parameter.Turbine.HubHeight;
                Parameter.TurbSim.RefHt             = Parameter.Turbine.HubHeight;
                
                
                
                %% TurbSim Modifications
                Parameter = setTurbSimInputModifications(Parameter);
                
                
                % SimulationName
                SimulationName                      = GetSimulationName(PreProcessingVariation,Variation,{'%02d','%01d'});
                Parameter.TurbSimNewInputFiles{1}   = [SimulationName,'.inp'];
                Parameter.TurbSim.WindFieldName     = SimulationName;
                
            case 'PostProcessing'
                PostProcessingConfig.TurbSim.ExportDisturbanceHH    = 1;
                PostProcessingConfig.v_0EstmationMethod             = 'v_0';
                Parameter.v_0 = [];
                %% Channels ------------------------------------------------
                PostProcessingConfig.Channels               = {
                    'v_0'	'v_0'       %1
                    
                    };
                
                % Statistics ----------------------------------------------
                nChannel = size(PostProcessingConfig.Channels,1);
                %----------
                PostProcessingConfig.Statistics.Config.tStartMin          	= 150;
                PostProcessingConfig.Statistics.MEAN.Channel               	= [1:nChannel];
                PostProcessingConfig.Statistics.MIN.Channel                	= [1:nChannel];
                PostProcessingConfig.Statistics.MAX.Channel               	= [1:nChannel];
                PostProcessingConfig.Statistics.STD.Channel               	= [1:nChannel];
                
                
        end
    
end

%% Create Direcories only during PreProcessing
if strcmp(Purpose,'PreProcessing')
    if ~exist(ResultsFilesDir)
        mkdir(ResultsFilesDir)
    end
    if ~exist(ProcessingDir)
        mkdir(ProcessingDir)
    end
    if ~exist([ProcessingDir,'\done'])
        mkdir([ProcessingDir,'\done'])
    end
end
%% Outputs
switch Purpose
    case 'GetNumberOfProcesses'
        varargout{1}    = nProcess;
    case 'GetPreProcessingVariation'
        varargout{1}    = PreProcessingVariation;
        varargout{2}    = ProcessName;
        varargout{3}    = ResultsFilesDir;
    case 'PreProcessing'
        varargout{1}    = ProcessName;
        varargout{2}    = ProcessingDir;
        varargout{3}    = ResultsFilesDir;
        varargout{4}    = SimulationName;
        varargout{5}    = Parameter;
    case 'Processing'
        varargout{1}    = ProcessingDir;
        varargout{2}    = ResultsFilesDir;
    case 'PostProcessing'
        varargout{1}    = ProcessName;
        varargout{2}    = ResultsFilesDir;
        varargout{3}    = PostProcessingConfig;
end

end

