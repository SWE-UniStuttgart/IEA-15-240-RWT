%% BModes Post Processing

path2fig = 'D:\Projects\COREWIND\WP1\ACTIVEFLOAT\Bmodes';
plotRoot = 'Ativefloat_';

path2BModesEvalXls = 'D:\Projects\COREWIND\WP1\ACTIVEFLOAT\Bmodes\BModesEval.xlsx';
span_loc = xlsread(path2BModesEvalXls,'C4:C13');
FAdispM1_ = xlsread(path2BModesEvalXls,'D4:D13');
FAdispM2_ = xlsread(path2BModesEvalXls,'E4:E13');
SSdispM1_ = xlsread(path2BModesEvalXls,'F4:F13');
SSdispM2_ = xlsread(path2BModesEvalXls,'G4:G13');

FAdispM1 = FAdispM1_./FAdispM1_(end);
FAdispM2 = FAdispM2_./FAdispM2_(end);
SSdispM1 = SSdispM1_./SSdispM1_(end);
SSdispM2 = SSdispM2_./SSdispM2_(end);

figure; 
subplot(121)
plot(FAdispM1,span_loc,'LineWidth',3)
xlabel('1st mode, f-a displacement')
ylabel('norm. tower height [-]')
set(gca,'FontSize',14)
subplot(122)
plot(FAdispM2,span_loc,'LineWidth',3)
xlabel('2nd mode, f-a displacement')   
set(gca,'FontSize',14)
set(gcf,'Units','pixels', 'Position',[0 0 700 500])
set(gcf,'PaperPositionMode','auto')
print([path2fig, plotRoot, 'ModeShapes'],'-dpng')

% polynomial curve fitting
f = fittype('c*x^2+d*x^3+e*x^4+f*x^5+g*x^6');
[FAM1fit,gof,fitinfo] = fit(span_loc,FAdispM1,f,'StartPoint',[1 1 1 1 1]);
[FAM2fit,gof,fitinfo] = fit(span_loc,FAdispM2,f,'StartPoint',[1 1 1 1 1]);
[SSM1fit,gof,fitinfo] = fit(span_loc,SSdispM1,f,'StartPoint',[1 1 1 1 1]);
[SSM2fit,gof,fitinfo] = fit(span_loc,SSdispM2,f,'StartPoint',[1 1 1 1 1]);

FASTFAM1Input = [FAM1fit.c; FAM1fit.d; FAM1fit.e; FAM1fit.f; FAM1fit.g]
FASTFAM2Input = [FAM2fit.c; FAM2fit.d; FAM2fit.e; FAM2fit.f; FAM2fit.g]
FASTFSS1Input = [SSM1fit.c; SSM1fit.d; SSM1fit.e; SSM1fit.f; SSM1fit.g]
FASTFSS2Input = [SSM2fit.c; SSM2fit.d; SSM2fit.e; SSM2fit.f; SSM2fit.g]

sumFASTFAM1Input = FAM1fit.c + FAM1fit.d + FAM1fit.e + FAM1fit.f + FAM1fit.g
sumFASTFAM2Input = FAM2fit.c + FAM2fit.d + FAM2fit.e + FAM2fit.f + FAM2fit.g
sumFASTFSS1Input = SSM1fit.c + SSM1fit.d + SSM1fit.e + SSM1fit.f + SSM1fit.g
sumFASTFSS2Input = SSM2fit.c + SSM2fit.d + SSM2fit.e + SSM2fit.f + SSM2fit.g

figure; plot(FAM1fit',span_loc,FAdispM1,'x')
figure; plot(FAM2fit',span_loc,FAdispM2,'x')
figure; plot(SSM1fit',span_loc,SSdispM1,'x')
figure; plot(SSM2fit',span_loc,SSdispM2,'x')