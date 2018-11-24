function [WMAVect] = WMA(n,VectPrice)

NbRow = size(VectPrice,1);

% D�finition des poids � utiliser
for i = 1:n
    Weights(i,1) = i; %n-i+1;
end

% Calcul de la moyenne mobile
for i = n:NbRow
    PriceIP = VectPrice(i-n+1:i,1);
    WMAVect(i,1) = (Weights'*PriceIP)/sum(Weights);
end

end

