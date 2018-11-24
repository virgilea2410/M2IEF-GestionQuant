function [Data_CDS, Data_Bond, Import_Govt, Import_Swap, Names, Names_Swap, Names_Govt, Dates_Main, Equi] = ImportDataMain()


[Data_CDS, Text_CDS] = xlsread('Data GQ.xlsx','CDS');
Names = Text_CDS(1,2:end);
Dates_Main = Text_CDS(3:end,1);

[Data_Bond, ~] = xlsread('Data GQ.xlsx','BONDS');

[Import_Swap, Text_Swap] = xlsread('Data GQ.xlsx','SWAPS');
Names_Swap = Text_Swap(1,2:end);

[Import_Govt, Text_Govt] = xlsread('Data GQ.xlsx','GOVT');
Names_Govt = Text_Govt(1,2:end);

[~, Equi] = xlsread('Data GQ.xlsx','Equi');

% iMac
if ismac || isunix
    Date_CDS = Data_CDS(:,1);
    Dates_Main = Data_CDS(:,1);
    Data_CDS = Data_CDS(:,2:end);

    Data_Bond = Data_Bond(:,2:end);

    Date_Swap = Import_Swap(:,1);
    Date_Govt = Import_Govt(:,1);

    Import_Swap = Import_Swap(:,2:end);
    Import_Govt = Import_Govt(:,2:end);
end

end
