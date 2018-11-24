function [currentPnL, currentBpsPnL] = RatioRevertBacktester(aCDSPrice,aCSPrice,window, numStd)

    nObs = size(aCDSPrice,1);
    pos = 0;
    currentPnL=0;
    currentBpsCDS = 0;
    currentBpsCS = 0;
    
    % Boolean utilisé pour detecter quand le spread passe pour la deuxième
    % fois le signal (quand il revient vers la moyenne, donc)
    time2revertCDS = false;
    time2revertCS = false;
    
    i=window;
    
    while  i<nObs
        
        %stdCS30D = std(aCSPrice(i-window+1:i, 1));
        %stdCDS30D = std(aCDSPrice(i-window+1:i, 1));
        stdCDS = std(aCDSPrice(i-window+1:i, 1)./aCSPrice(i-window+1:i, 1));
        stdCS = std(aCSPrice(i-window+1:i, 1)./aCDSPrice(i-window+1:i, 1));
        
        rollCDSPriceRatio = mean(aCDSPrice(i-window+1:i, 1)./aCSPrice(i-window+1:i, 1));
        rollCSPriceRatio = mean(aCSPrice(i-window+1:i, 1)./aCDSPrice(i-window+1:i, 1));
        
        if pos == 0 % Pas de position
            
            %if aCDSPrice(i,1)/aCSPrice(i,1) > priceRatio * (1 + stdCDS30D * numStd) % Achat CS Vente CDS
            if aCDSPrice(i,1)/aCSPrice(i,1) > rollCDSPriceRatio * (1 + stdCDS * numStd) % Achat CS Vente CDS
                
                if not(time2revertCDS)
                    time2revertCDS = true;
                end
                
            %elseif aCSPrice(i,1)/aCDSPrice(i,1) > priceRatio * (1 + stdCS30D * numStd) % Achat CDS Vente CS
            elseif aCSPrice(i,1)/aCDSPrice(i,1) > rollCSPriceRatio * (1 + stdCS * numStd) % Achat CDS Vente CS
                
                if not(time2revertCS)
                    time2revertCS = true;
                end
                
            end
                
            if time2revertCDS
                if aCDSPrice(i,1)/aCSPrice(i,1) <= rollCDSPriceRatio * (1 + stdCDS * numStd) % Achat CS Vente CDS
                    pos =-1;
                    buyPriceCS = aCSPrice(i,1);
                    sellPriceCDS = aCDSPrice(i,1);
                    time2revertCDS = false;
                end
            end
            
            if time2revertCS
                if aCSPrice(i,1)/aCDSPrice(i,1) <= rollCSPriceRatio * (1 + stdCS * numStd) % Achat CDS Vente CS
                    pos =1;
                    buyPriceCDS = aCDSPrice(i,1);
                    sellPriceCS = aCSPrice(i,1);
                    time2revertCS = false;
                end
            end
                
            currentPnL = currentPnL - aCDSPrice(i,1)*pos + aCSPrice(i,1)*pos;
            
        else
            
            if pos == 1 && aCSPrice(i,1)/aCDSPrice(i,1) < rollCSPriceRatio % Achat CS Vente CDS
                pos = 0;
                buyPriceCS = aCSPrice(i,1);
                sellPriceCDS = aCDSPrice(i,1);
                currentPnL = currentPnL + aCDSPrice(i,1) - aCSPrice(i,1);
                currentBpsCS = (sellPriceCS - buyPriceCS)/buyPriceCS;
                currentBpsCDS = (sellPriceCDS - buyPriceCDS)/buyPriceCDS;
                
            elseif pos==-1 && aCDSPrice(i,1)/aCSPrice(i,1) < rollCDSPriceRatio % Achat CDS Vente CS
                pos =0;
                buyPriceCDS = aCDSPrice(i,1);
                sellPriceCS = aCSPrice(i,1);
                currentPnL = currentPnL - aCDSPrice(i,1) + aCSPrice(i,1);
                currentBpsCS = (sellPriceCS - buyPriceCS)/buyPriceCS;
                currentBpsCDS = (sellPriceCDS - buyPriceCDS)/buyPriceCDS;
                
            end
            
        end
        
        i=i+1;
    end
    
    if pos ~= 0 
         if pos == 1  % Achat CS Vente CDS
            pos = 0;
            currentPnL=currentPnL + aCDSPrice(nObs,1) - aCSPrice(nObs,1);
            buyPriceCS = aCSPrice(i,1);
            sellPriceCDS = aCDSPrice(i,1);
            currentBpsCS = (sellPriceCS - buyPriceCS)/buyPriceCS;
            currentBpsCDS = (sellPriceCDS - buyPriceCDS)/buyPriceCDS;
            
        elseif pos == -1  % Achat CDS Vente CS
            pos = 0;
            currentPnL=currentPnL - aCDSPrice(nObs,1) + aCSPrice(nObs,1);
            buyPriceCDS = aCDSPrice(i,1);
            sellPriceCS = aCSPrice(i,1);
            currentBpsCS = (sellPriceCS - buyPriceCS)/buyPriceCS;
            currentBpsCDS = (sellPriceCDS - buyPriceCDS)/buyPriceCDS;
            
         end
    end

    currentBpsPnL = currentBpsCS + currentBpsCDS;
    
end

