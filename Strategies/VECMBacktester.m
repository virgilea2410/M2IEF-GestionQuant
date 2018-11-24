% FONCTION DE BACKTEST D'UNE STRATEGIE PAIR D'ARBITRAGE LONG/SHORT CS vs CDS POUR LES MODELES VAR
% INPUTS:
%   - aCDSPrice  = Vecteur de prix de CDS
%   - aCSPrice   = Vecteur de prix de CS
%   - VarMdl     = Objet contenant le mod�le VAR (coefficiants et constante)
% OUTPUT:
%   - currentPnL = PnL obtenu par lors du backtest de la strat�gie

function [currentPnL, currentBpsPnL] = VECMBacktester(aCDSPrice, aCSPrice, aWindow, K)
    
    nObs = size(aCDSPrice,1);
    Lag = FindVARLag([aCDSPrice,aCSPrice], 0, 10);
    pos = 0;
    currentPnL = 0;
    currentBpsCDS = 0;
    currentBpsCS = 0;
    
    buyPrice = 0;
    sellPrice = 0;
    
    if not(exist("K"))    
        K = 1.5;
    end
    
    if not(exist("aWindow"))    
        aWindow = 42;
    end
    
    %i = numLag + 1;
    i = aWindow;
    while  i < nObs
        
        if mod(i, aWindow) == 0 || abs(Spread) > 2 * K * stdSpread
            MyVECM = vecm(2, 1, Lag);
            %myEstVECM = estimate(MyVECM, [aCDSPrice(1:i,:),aCSPrice(1:i,:)]);
            myEstVECM = estimate(MyVECM, [aCDSPrice(i-aWindow+1:i,:),aCSPrice(i-aWindow+1:i,:)]);
        end
        
        Spread = myEstVECM.CointegrationConstant + (aCDSPrice(i-1, 1) * myEstVECM.Cointegration(1,1) + aCSPrice(i-1, 1) * myEstVECM.Cointegration(2,1));
        
        if i == aWindow
            spreadHisto = myEstVECM.CointegrationConstant + (aCDSPrice(1:i, 1) * myEstVECM.Cointegration(1,1) + aCSPrice(1:i, 1) * myEstVECM.Cointegration(2,1));
        else
            spreadHisto = [spreadHisto; Spread];
        end
        
        %stdSpread = std(spreadHisto);
        stdSpread = std(spreadHisto(i-aWindow+1:i,:));
        avgSpread = mean(spreadHisto(i-aWindow+1:i,:));
        
        if pos == 0% Pas de position
            
            if  Spread < avgSpread - K * stdSpread
                wCDS =  myEstVECM.Cointegration(1,1);
                wCS = myEstVECM.Cointegration(2,1);
                
                currentPnL = currentPnL - (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
                
                PriceCS = aCSPrice(i,1);
                PriceCDS = aCDSPrice(i,1);
                
                pos = 1;
            elseif Spread > avgSpread + K * stdSpread
                wCDS =  myEstVECM.Cointegration(1,1);
                wCS = myEstVECM.Cointegration(2,1);
                
                currentPnL = currentPnL + (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
                
                PriceCS = aCSPrice(i,1);
                PriceCDS = aCDSPrice(i,1);
                
                pos = -1;
            end
            
        end
    
        if not(pos == 0)
            
            if pos == 1 && Spread > avgSpread
                pos = 0;
                
                currentPnL = currentPnL + (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
                
                exitPriceCS = aCSPrice(i,1);
                exitPriceCDS = aCDSPrice(i,1);
                
                currentBpsCS = (exitPriceCS - PriceCS) / (PriceCS) * wCS;
                currentBpsCDS = (exitPriceCDS - PriceCDS) / (PriceCDS) * wCDS;
                
            elseif pos == -1 && Spread < avgSpread
                pos = 0;
                
                currentPnL = currentPnL - (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
                
                exitPriceCS = aCSPrice(i,1);
                exitPriceCDS = aCDSPrice(i,1);
                
                currentBpsCS = (exitPriceCS - PriceCS) / (PriceCS) * wCS;
                currentBpsCDS = (exitPriceCDS - PriceCDS) / (PriceCDS) * wCDS;
            end
            
        end
        
        i = i+1;
    end
    
    if not(pos == 0)
         if pos == 1
            
            currentPnL = currentPnL + (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
            
            exitPriceCS = aCSPrice(i,1);
            exitPriceCDS = aCDSPrice(i,1);
            
            currentBpsCS = (exitPriceCS - PriceCS) / (PriceCS) * wCS;
            currentBpsCDS = (exitPriceCDS - PriceCDS) / (PriceCDS) * wCDS;
            
            pos = 0;
            
        elseif pos == -1
            
            exitPriceCS = aCSPrice(i,1);
            exitPriceCDS = aCDSPrice(i,1);
            
            currentPnL = currentPnL - (aCDSPrice(i, 1) * wCDS + aCSPrice(i, 1) * wCS);
            
            currentBpsCS = (exitPriceCS - PriceCS) / (PriceCS) * wCS;
            currentBpsCDS = (exitPriceCDS - PriceCDS) / (PriceCDS) * wCDS;
            
            pos = 0;
            
         end
    end
    
    currentBpsPnL = currentBpsCS + currentBpsCDS;
    
end

