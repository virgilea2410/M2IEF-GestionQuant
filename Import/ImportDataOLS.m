function [Import_OLSGov2Y, Import_OLSGov10Y, Import_OLSPut, Import_OLSOOTR, Import_OLSIndex, Import_OLSStock, Names_OLSGov2Y, Names_OLSGov10Y, Names_OLSPut, Names_OLSIndex, Dates_OLS] = ImportDataOLS()


[Import_OLSGov2Y, Text_OLSGov2Y] = xlsread('Data GQ.xlsx','OLS_GOV_2Y');
Names_OLSGov2Y = Text_OLSGov2Y(1,2:end);
Dates_OLS = Text_OLSGov2Y(2:end,1);

[Import_OLSGov10Y, Text_OLSGov10Y] = xlsread('Data GQ.xlsx','OLS_GOV_10Y');
Names_OLSGov10Y = Text_OLSGov10Y(1,2:end);

[Import_OLSPut, Text_OLSPut] = xlsread('Data GQ.xlsx','OLS_PUT');
Names_OLSPut = Text_OLSPut(1,2:end);

[Import_OLSOOTR, ~] = xlsread('Data GQ.xlsx','OLS_OOTR');

[Import_OLSIndex, Text_OLSIndex] = xlsread('Data GQ.xlsx','OLS_INDEX');
Names_OLSIndex = Text_OLSIndex(1,2:end);

[Import_OLSStock, ~] = xlsread('Data GQ.xlsx','OLS_STOCK');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iMac
if ismac || isunix
    Dates_OLS = Import_OLSGov2Y(:,1);
    Date_OLSGov2Y = Import_OLSGov2Y(:,1);
    Import_OLSGov2Y = Import_OLSGov2Y(:,2:end);
    Import_OLSGov10Y = Import_OLSGov10Y(:,2:end);
    Import_OLSPut = Import_OLSPut(:,2:end);
    Import_OLSOOTR = Import_OLSOOTR(:,2:end);
    Import_OLSStock = Import_OLSStock(:,2:end);
    Import_OLSIndex = Import_OLSIndex(:,2:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end