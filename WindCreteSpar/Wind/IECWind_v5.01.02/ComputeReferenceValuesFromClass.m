function [I_ref,V_ref] = ComputeReferenceValuesFromClass(Class)


TurbulenceChar = lower(Class(end));
switch TurbulenceChar
    case 'a'
        I_ref = .16;
    case 'b'
        I_ref = .14;
    case 'c'
        I_ref = .12;
    otherwise
        error('Please check your turbine class format')
end

TurbineClass = upper(Class(1:end-1));
switch TurbineClass
    case 'I'
        V_ref = 50;
    case 'II'
        V_ref = 42.5;
    case 'III'
        V_ref = 37.5;
    otherwise
        error('Please check your turbine class format')
end
