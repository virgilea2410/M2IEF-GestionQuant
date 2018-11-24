function PnL = HMABactester(PriceMat, MAPriceMat, n, NbBPToAct)

for i=1:size(MAPriceMat,2)
    PriceVect = PriceMat(:,i);
    MAPriceVect = MAPriceMat(:,i);
    
    % Calcul de la Moyenne Mobile HMA
    VectWMAn = WMA(n,MAPriceVect);
    VectWMAn2 = WMA(round(n/2),MAPriceVect);

    VectIP = 2*VectWMAn2 - VectWMAn;

    HMA = WMA(round(sqrt(n)),VectIP);


    % Calcul du PnL
    k = n;
    PnL(1,i) = 0;
    Pos = false;
    while (k < size(PriceVect,1))
        if HMA(k,1) > PriceVect+NbBPToAct
            if Pos == false; EnterPosVal = PriceVect(k,1); end
            Pos = true;
        elseif HMA(k,1) < PriceVect-NbBPToAct
            if Pos == true
                OutPosVal = PriceVect(k,1);
                PnL(1,i) = PnL(1,i) + ((EnterPosVal/OutPosVal)-1);
                EnterPosVal = 0;
                OutPosVal = 0;
            end
            Pos = false;
        end
        k = k+1;
    end

end
end

