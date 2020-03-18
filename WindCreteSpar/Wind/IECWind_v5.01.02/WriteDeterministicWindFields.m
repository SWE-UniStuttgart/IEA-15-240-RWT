function WriteDeterministicWindFields(DLBCase,Variation,Parameter,SimulationName,WindDir)

Parameter.Time.TMin         = 0;
Parameter.Time.TMax        	= DLBCase.TStart+DLBCase.T;


switch DLBCase.DLCName
    
    
    case "1d4"
        t_ECD_Start = 100;
        HHData  = CalculateIECECD(Variation,Parameter,t_ECD_Start);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case "1d5"
        t_EWS_Start = 100;
        switch Variation(4)
            case 1
                Direction = 'vertical';
                ShearSign = 1;
            case 2
                Direction = 'vertical';
                ShearSign = -1;
            case 3
                Direction = 'horizontal';
                ShearSign = 1;
            case 4
                Direction = 'horizontal';
                ShearSign = -1;
            otherwise
                error('No additional variation given to define EWS!');
        end
        HHData  	= CalculateIECEWS(Variation,Parameter,t_EWS_Start,Direction,ShearSign);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case "2d3"
        % grid loss at three different times after gust has started
        t_EOG_Start = Variation(4);
        HHData  	= CalculateIECEOG(Variation,Parameter,t_EOG_Start);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case {"3d1","4d1"}
        HHData  = CalculateNWP(Variation,Parameter);
        
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case "3d2"
        %, the start-up is initiated at four different time instances after the gust has started.
        t_EOG_Start = Variation(4);
        HHData  = CalculateIECEOG(Variation,Parameter,t_EOG_Start);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case "3d3"
        % two timings for each sign of the direction change is used: start-up is just before the
        % direction change and one half way through the direction change.
        switch Variation(4)
            case 1
                t_EDC_Start = 100;
                DirSign     = 1;
            case 2
                t_EDC_Start = 100;
                DirSign     = -1;
            case 3
                t_EDC_Start = 103;
                DirSign     = 1;
            case 4
                t_EDC_Start = 103;
                DirSign     = -1;
            otherwise
                error('No additional variation given to define EDC!');
        end
        HHData  = CalculateIECEDC(Variation,Parameter,t_EDC_Start,DirSign);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
    case "4d2"
        t_EOG_Start = Variation(4);
        HHData  = CalculateIECEOG(Variation,Parameter,t_EOG_Start);
        WriteHHWindField(HHData,[WindDir,SimulationName,'.wnd']);
        
end








function HHData  = CalculateIECEOG(Variation,Parameter,t_EOG_Start)
% Extreme Operating Gust

% HHData = [Time WindSpeed WindDir VerticalSpeed HorShear PwrLawVrtShear LinVertShear GustSpeed]


URef            = Variation(1);
dt              = .1;
TMin            = Parameter.Time.TMin;
TMax            = Parameter.Time.TMax;
RotorDiameter   = Parameter.Turbine.R*2;
HubHeight       = Parameter.Turbine.HubHeight;
[I_ref,V_ref]   = ComputeReferenceValuesFromClass(Parameter.Turbine.Class);

sigma_1         = I_ref*(3/4*URef+5.6);
Lambda_1        =((0.7*HubHeight)*(HubHeight<60)+(42)*(HubHeight>=60));
v_e50           = 1.4*V_ref;
v_e1            = 0.8*v_e50;
v_gust          = min(1.35*(v_e1-URef),3.3*sigma_1/(1+0.1*RotorDiameter/Lambda_1));
T               = 10.5;
t_eog           = 0:dt:T;

gust            = -0.37*v_gust*sin(3*pi*t_eog/T).*(1-cos(2*pi*t_eog/T));

% avoid duplicate lines by including _ [Start EOG END]
Time            = [TMin  t_EOG_Start-dt:dt:t_EOG_Start+T+dt TMax]';


GustSpeed       = interp1(t_EOG_Start+t_eog,gust,Time,'linear',0);

one             = ones(size(Time));

HHData          = [Time one*URef*cos(Parameter.TurbSim.InflowInclination) ...
    0*one (URef+GustSpeed)*sin(Parameter.TurbSim.InflowInclination) 0*one Parameter.TurbSim.Shear*one ...
    0*one GustSpeed];

function HHData  = CalculateIECECD(Variation,Parameter,t_ECD_Start)
% Extreme coherent gust with direction Change

% HHData = [Time WindSpeed WindDir VerticalSpeed HorShear PwrLawVrtShear LinVertShear GustSpeed]


URef            = Variation(1);
dt              = .1;
TMin            = Parameter.Time.TMin;
TMax            = Parameter.Time.TMax;
RotorDiameter   = Parameter.Turbine.R*2;
HubHeight       = Parameter.Turbine.HubHeight;
[I_ref,V_ref]   = ComputeReferenceValuesFromClass(Parameter.Turbine.Class);

V_cg            = 15;
T               = 10;
t_ecd           = 0:dt:T;

% avoid duplicate lines by including _ [Start EOG END]
Time            = [TMin  t_ECD_Start-dt:dt:t_ECD_Start+T TMax]';



% GUST
gust            = .5*V_cg*(1-cos(pi.*t_ecd/T));
% add values to grid vector to enable "hold first/last value behaviour"
GustSpeed       = interp1([TMin t_ECD_Start+t_ecd TMax],[0 gust gust(end)],Time,'linear',0);

% DIRECTION CHANGE
theta_cg        = deg2rad(180)*(URef<=4) + deg2rad(720/URef) * (URef>4);


theta_gust      = .5*theta_cg*(1-cos(pi.*t_ecd/T));

% add values to grid vector to enable "hold first/last value behaviour"
GustDir         = rad2deg(interp1([TMin t_ECD_Start+t_ecd TMax],[0 theta_gust theta_cg],Time,'linear',0));


one             = ones(size(Time));

HHData          = [Time one*URef*cos(Parameter.TurbSim.InflowInclination) ...
    GustDir (URef+GustSpeed)*sin(Parameter.TurbSim.InflowInclination) 0*one Parameter.TurbSim.Shear*one ...
    0*one GustSpeed];

function HHData  = CalculateIECEWS(Variation,Parameter,t_EWS_Start,Direction,ShearSign)
% Extreme Wind Shear

% HHData = [Time WindSpeed WindDir VerticalSpeed HorShear PwrLawVrtShear LinVertShear GustSpeed]

URef            = Variation(1);
dt              = .1;
TMin            = Parameter.Time.TMin;
TMax            = Parameter.Time.TMax;
RotorDiameter   = Parameter.Turbine.R*2;
HubHeight       = Parameter.Turbine.HubHeight;
[I_ref,V_ref]   = ComputeReferenceValuesFromClass(Parameter.Turbine.Class);



%% compute IEC EWS
%


beta          	= 6.4;
T            	= 12;
sigma_1       	= I_ref*(0.75*URef+5.6);
Lambda_1      	=((0.7*HubHeight)*(HubHeight<60)+(42)*(HubHeight>=60));


t_EWS          	= 0:dt:T;


% avoid duplicate lines by including _ [Start EOG END]
Time            = [TMin  t_EWS_Start-dt:dt:t_EWS_Start+T TMax]';



% linear shear based on calculation of V in InflowWind (see docu
% p.9)(RefLength = D; RefHt = HH)
ShearMax       	= (2.5*+0.2*beta*sigma_1*(RotorDiameter/Lambda_1)^(1/4))/URef;
ShearV        	= ShearSign*ShearMax*(1-cos(pi.*t_EWS/T));
ShearH         	= ShearSign*ShearMax*(1-cos(pi.*t_EWS/T));

% add values to grid vector to enable "hold first/last value behaviour"
ShearGustV_calc = interp1(t_EWS_Start+t_EWS,ShearV,Time,'linear',0);
ShearGustH_calc = interp1(t_EWS_Start+t_EWS,ShearH,Time,'linear',0);

one           	= ones(size(Time));

switch Direction
    case 'horizontal'
        ShearGustH = ShearGustH_calc;
        ShearGustV = 0*one;
    case 'vertical'
        ShearGustH = 0*one;
        ShearGustV = ShearGustV_calc;
end

HHData        	= [Time one*URef*cos(Parameter.TurbSim.InflowInclination) ...
    0*one  one*(URef)*sin(Parameter.TurbSim.InflowInclination) ShearGustH Parameter.TurbSim.Shear*one ...
    ShearGustV 0*one];

function HHData  = CalculateIECEDC(Variation,Parameter,t_EDC_Start,DirSign)
% Extreme Direction Change

% HHData = [Time WindSpeed WindDir VerticalSpeed HorShear PwrLawVrtShear LinVertShear GustSpeed]

URef            = Variation(1);
dt              = .1;
TMin            = Parameter.Time.TMin;
TMax            = Parameter.Time.TMax;
RotorDiameter   = Parameter.Turbine.R*2;
HubHeight       = Parameter.Turbine.HubHeight;
[I_ref,V_ref]   = ComputeReferenceValuesFromClass(Parameter.Turbine.Class);


T            	= 6;
sigma_1       	= I_ref*(0.75*URef+5.6);
Lambda_1      	= ((0.7*HubHeight)*(HubHeight<60)+(42)*(HubHeight>=60));



% avoid duplicate lines by including _ [Start EOG END]
Time            = [TMin  t_EDC_Start-dt:dt:t_EDC_Start+T TMax]';
t_edc           = 0:dt:T;


% DIRECTION CHANGE
theta_e         = 4*atan(sigma_1/(URef*(1+0.1*(RotorDiameter/Lambda_1))));
theta_e         = DirSign*min(deg2rad(180),abs(theta_e));


theta_gust      = .5*theta_e*(1-cos(pi.*t_edc/T));

% add values to grid vector to enable "hold first/last value behaviour"
GustDir         = rad2deg(interp1([TMin t_EDC_Start+t_edc TMax],[0 theta_gust theta_e],Time,'linear',0));


one             = ones(size(Time));

HHData          = [Time one*URef*cos(Parameter.TurbSim.InflowInclination) ...
    GustDir one*URef*sin(Parameter.TurbSim.InflowInclination) 0*one Parameter.TurbSim.Shear*one ...
    0*one  0*one];

function HHData  = CalculateNWP(Variation,Parameter)
% Normal Wind Profile

% HHData = [Time WindSpeed WindDir VerticalSpeed HorShear PwrLawVrtShear LinVertShear GustSpeed]


URef            = Variation(1);
TMin            = Parameter.Time.TMin;
TMax            = Parameter.Time.TMax;
HubHeight       = Parameter.Turbine.HubHeight;



% two lines are enough
Time            = [TMin TMax]';

one             = ones(size(Time));

HHData          = [Time one*URef*cos(Parameter.TurbSim.InflowInclination) ...
    0*one one*URef*sin(Parameter.TurbSim.InflowInclination) 0*one Parameter.TurbSim.Shear*one ...
    0*one  0*one];
