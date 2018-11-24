% FONCTION DE BACKTEST D'UNE STRATEGIE PAIR D'ARBITRAGE LONG/SHORT CS vs CDS POUR LES MODELES VAR
% INPUTS:
%   - aCDSPrice  = Vecteur de prix de CDS
%   - aCSPrice   = Vecteur de prix de CS
%   - VarMdl     = Objet contenant le mod�le VAR (coefficiants et constante)
% OUTPUT:
%   - currentPnL = PnL obtenu par lors du backtest de la strat�gie

function [currentPnL, currentBpsPnL] = VARBacktester(aCDSPrice, aCSPrice)

    aBPToAct = 0;
    
    nObs = size(aCDSPrice,1);
    Lag = FindVARLag([aCDSPrice,aCSPrice], 0, 10);
    posCDS = 0;
    posCS = 0;
    currentPnL = 0;
    currentBpsCDS = 0;
    currentBpsCS = 0;
    
    %i = numLag + 1;
    i = 50;
    while  i < nObs
        
        % Estimation du modèle VAR toutes les 50 observations
        if mod(i, 50) == 0
            MyVarMdl = varm(2, Lag);
            myModel = estimate(MyVarMdl, [aCDSPrice(1:i,:),aCSPrice(1:i,:)]);

            numLag = myModel.P;

            for j = 1:numLag
                arCDS(j,1) = myModel.AR{1,j}(1,1);
                arCDS(j+numLag,1) = myModel.AR{1,j}(1,2);
            end
            VarCDS = [myModel.Constant(1,1) arCDS'];

            for j = 1:numLag
                arCS(j,1) = myModel.AR{1,j}(2,1);
                arCS(j+numLag,1) = myModel.AR{1,j}(2,2);
            end
            VarCS = [myModel.Constant(2,1) arCS'];
        end
        
        % Calcul du prix esrtime a chaque periode
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

                buyPriceCS = aCSPrice(i,1);
                sellPriceCDS = aCDSPrice(i,1);
                currentPnL = currentPnL - aCSPrice(i,1) + aCDSPrice(i,1);
                
            elseif (aCSPrice(i,1) > estimationCS) && (aCDSPrice(i,1) < estimationCDS)
                posCDS = 1; % Achat CDS
                posCS = -1; % Vente CS

                sellPriceCS = aCSPrice(i,1);
                buyPriceCDS = aCDSPrice(i,1);
                currentPnL = currentPnL + aCSPrice(i,1) - aCDSPrice(i,1);
            end
        end
    
        if not(posCS == 0) && not(posCDS == 0)
            
            if posCS == 1 && aCSPrice(i,1) > estimationCS + aBPToAct
                posCS = 0; % Vente CS
                posCDS = 0; % Achat CDS

                buyPriceCDS = aCDSPrice(i,1);
                sellPriceCS = aCSPrice(i,1);
                currentPnL = currentPnL + aCSPrice(i,1) - aCDSPrice(i,1);
                currentBpsCDS = currentBpsCDS + (sellPriceCDS-buyPriceCDS)/abs(buyPriceCDS);
                currentBpsCS = currentBpsCS + (sellPriceCS-buyPriceCS)/abs(buyPriceCS);
                
            elseif posCS ==-1 && aCSPrice(i,1) < estimationCS + aBPToAct
                posCS = 0; % Achat CS
                posCDS = 0; % Vente CDS

                sellPriceCDS = aCDSPrice(i,1);
                buyPriceCS = aCSPrice(i,1);
                currentPnL = currentPnL - aCSPrice(i,1) + aCDSPrice(i,1);
                currentBpsCDS = currentBpsCDS + (sellPriceCDS-buyPriceCDS)/abs(buyPriceCDS);
                currentBpsCS = currentBpsCS + (sellPriceCS-buyPriceCS)/abs(buyPriceCS);

            end
            
        end
        
        i = i+1;
    end
    
    if not(posCS == 0) && not(posCDS == 0)
         if posCS == 1 && posCDS == -1
            % Vente CS
            % Achat CDS
            buyPriceCDS = aCDSPrice(nObs,1);
            sellPriceCS = aCSPrice(nObs,1);
            currentPnL = currentPnL + aCSPrice(nObs,1) - aCDSPrice(nObs,1);
            currentBpsCDS = currentBpsCDS + (sellPriceCDS-buyPriceCDS)/abs(buyPriceCDS);
            currentBpsCS = currentBpsCS + (sellPriceCS-buyPriceCS)/abs(buyPriceCS);

            posCS = 0;
            posCDS = 0;
            
        elseif posCDS == 1 && posCS == -1
            % Achat CS
            % Vente CDS
            sellPriceCDS = aCDSPrice(nObs,1);
            buyPriceCS = aCSPrice(nObs,1);
            currentPnL = currentPnL - aCSPrice(nObs,1) + aCDSPrice(nObs,1);
            currentBpsCDS = currentBpsCDS + (sellPriceCDS-buyPriceCDS)/abs(buyPriceCDS);
            currentBpsCS = currentBpsCS + (sellPriceCS-buyPriceCS)/abs(buyPriceCS);
            
            posCS = 0;
            posCDS = 0;
            
         end
    end
    
    currentBpsPnL = currentBpsCDS + currentBpsCS;
end

