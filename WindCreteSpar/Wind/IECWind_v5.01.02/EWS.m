% I_ref=0.14;
% b=5.6;
% V=12;
% sigma=I_ref*(0.75*V+b);
% T=12;
% i=1;
% for t=[0:0.1:12]
% V_shear(i,1)=(2.5+0.2*6.4*sigma*(240/42)^(0.25))*(1-cos(2*pi*t/T));
% i=i+1;
% end
URef            = 10.8;
dt              = .1;
TMin            = 0;
TMax            = 150;
RotorDiameter   = 240;
HubHeight       = 150;
[I_ref,V_ref]   = ComputeReferenceValuesFromClass('Ib');
InflowInclination=0;
Direction='vertical';
ShearSign=1;
alpha=0.2;
%% compute IEC EWS
%


beta          	= 6.4;
T            	= 100;
sigma_1       	= I_ref*(0.75*URef+5.6);
Lambda_1      	=((0.7*HubHeight)*(HubHeight<60)+(42)*(HubHeight>=60));
t_EWS_Start     =50;

t_EWS          	= 0:dt:T;


% avoid duplicate lines by including _ [Start EOG END]
Time            = [TMin  t_EWS_Start-dt:dt:t_EWS_Start+T TMax]';



% linear shear based on calculation of V in InflowWind (see docu
% p.9)(RefLength = D; RefHt = HH)
ShearMax       	= (2.5*+0.2*beta*sigma_1*(RotorDiameter/Lambda_1)^(1/4))/URef;
ShearV        	= ShearSign*ShearMax*(1-cos(2*pi.*t_EWS/T));
ShearH         	= ShearSign*ShearMax*(1-cos(2*pi.*t_EWS/T));

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

HHData        	= [Time one*URef*cos(InflowInclination) ...
    0*one  one*(URef)*sin(InflowInclination) ShearGustH alpha*one ...
    ShearGustV 0*one];
WriteHHWindField(HHData,['EWS',Direction,num2str(ShearSign),'.wnd']);