% FONCTION DE BACKTEST D'UNE STRATEGIE PAIR D'ARBITRAGE LONG/SHORT CS vs CDS POUR LES MODELES VAR
% INPUTS:
%   - aCDSPrice  = Vecteur de prix de CDS
%   - aCSPrice   = Vecteur de prix de CS
%   - VarMdl     = Objet contenant le mod�le VAR (coefficiants et constante)
% OUTPUT:
%   - currentPnL = PnL obtenu par lors du backtest de la strat�gie

function [currentPnL] = PairVARBacktester(aCDSPrice, aCSPrice, VarMdl)

    aBPToAct = 0;
    
    nObs = size(aCDSPrice,1);
    posCDS = 0;
    posCS = 0;
    currentPnL = 0;
    
    myModel = VarMdl{1,1};
    numLag = myModel.P;
    
    for i = 1:numLag
        arCDS(i,1) = myModel.AR{1,i}(1,1);
        arCDS(i+numLag,1) = myModel.AR{1,i}(1,2);
    end
    VarCDS = [myModel.Constant(1,1) arCDS'];
    
    for i = 1:numLag
        arCS(i,1) = myModel.AR{1,i}(2,1);
        arCS(i+numLag,1) = myModel.AR{1,i}(2,2);
    end
    VarCS = [myModel.Constant(2,1) arCS'];
    
    
    
    i = numLag + 1;
    while  i < nObs
        
        estimationCS = VarCS(1, 1);
        estimationCDS = VarCDS(1, 1);
        for i_lags = 1:numLag
            estimationCS = estimationCS + VarCS(1, i_lags + 1) * aCDSPrice(i - i_lags);
            estimationCDS = estimationCDS + VarCDS(1, i_lags + 1) * aCDSPrice(i - i_lags);
        end
        for i_lags = 1:numLag
            estimationCS = estimationCS + VarCS(1, i_lags + numLag+1) * aCSPrice(i - i_lags);
            estimationCDS = estimationCDS + VarCDS(1, i_lags + numLag+1) * aCSPrice(i - i_lags);
        end
        
        if posCS == 0 && posCDS == 0% Pas de position
            
            if (aCSPrice(i,1) < estimationCS) && (aCDSPrice(i,1) > estimationCDS)
                posCS = 1; % Achat CS
                posCDS = -1; % Vente CDS
            elseif (aCSPrice(i,1) > estimationCS) && (aCDSPrice(i,1) < estimationCDS)
                posCDS = 1; % Achat CDS
                posCS = -1; % Vente CS
            end
            
            currentPnL = currentPnL - aCSPrice(i,1)*posCS - aCDSPrice(i,1)*posCDS;
        end
    
        if not(posCS == 0) && not(posCDS == 0)
            
            if posCS == 1 && aCSPrice(i,1) > estimationCS + aBPToAct
                posCS = 0;
                posCDS = 0;
                currentPnL = currentPnL + aCSPrice(i,1);
            elseif posCS ==-1 && aCSPrice(i,1) < estimationCS + aBPToAct
                posCS = 0;
                posCDS = 0;
                currentPnL = currentPnL - aCSPrice(i,1);
            end
            
        end
        
        i = i+1;
    end
    
    if not(posCS == 0) && not(posCDS == 0)
         if posCS == 1 && posCDS == -1
            
            currentPnL = currentPnL - aCSPrice(nObs,1)*posCS - aCDSPrice(nObs,1)*posCDS;
            posCS = 0;
            posCDS = 0;
            
        elseif posCDS == 1 && posCS == -1
            
            currentPnL = currentPnL - aCSPrice(nObs,1)*posCS - aCDSPrice(nObs,1)*posCDS;
            
            posCS = 0;
            posCDS = 0;
            
         end
    end

end

