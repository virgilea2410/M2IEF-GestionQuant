function [optWindow, optK] = OptimiVECMBacktest(aCDS, aCS, maxK);


PnL = 0;
PreviousPnL = 0;
%MaxPnL = 0;

nbCol = size(aCDS, 2);
OptParam = zeros(nbCol,2);

for i_col = 1:nbCol
    MaxPnL(i_col, 1) = 0;
    
    % Calcul du Half Life Mean Reversion
    % Qui sera utilisé comme Window optimale pour les rolling params
    spread = aCDS(:, i_col) - aCS(:, i_col);
    diffSpread = diff(spread);
    spread = spread(2:end,1);
    spreadMdl = fitlm(spread, diffSpread);
    lambda = spreadMdl.Coefficients{2,1};
    HalfLifeMR = round(log(2)/lambda, 0);
    beginWindow = HalfLifeMR; 
    maxWindow = round(HalfLifeMR * 1.5, 0);

    if beginWindow <= 40 || beginWindow >= 100
        beginWindow = 40;
    end
    if maxWindow <= 45 || maxWindow >= 150
        maxWindow = 45;
    end
    
    for i_window = beginWindow:maxWindow
        for i_K = 1.9:0.1:maxK

           PnL = VECMBacktester(aCDS(:,i_col), aCS(:,i_col), i_window, i_K);

           if PnL > MaxPnL(i_col, 1)
               MaxPnL(i_col, 1) = PnL
               OptParam(i_col, :) = [i_window, i_K];
           end

           PreviousPnL = PnL;

        end
    end
end

optWindow = OptParam(1,1);
optK = OptParam(1,2);

end