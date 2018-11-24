% FONCTION CALCULANT LA VALEUR/RETURN D'UN PORTEFEUILLE EQUIPONDERE INVESTI DANS UN BENCHMARK
% INPUT:
%   - aBenchmark  = Matrice contenant les valeurs associé à un benchemark (contenant plusieurs entreprises en colonne)
% OUTPUTS:
%   - benchVal    = Vecteur par date contenant la valeur d'un portefeuille équipondéré investit dans le benchmark
%   - benchRet    = Rendement de la valeur du portefeuille équipondéré investit dans le benchmark

function [benchVal, benchRet] = HoldBenchmark(aBenchmark)

size_benchmark = size(aBenchmark, 2);
len_sample = size(aBenchmark, 1);

portfolio = zeros(len_sample, size_benchmark);
portfolio_value = zeros(1, len_sample);

equipond_coeff = 1/size_benchmark;

for i_companies = 1:size_benchmark
    portfolio(1, i_companies) = aBenchmark(1, i_companies) * equipond_coeff;
end

portfolio_value(1,1) = sum(portfolio(1,:));

for i_dates = 2:len_sample    
    for i_companies = 1:size_benchmark
        portfolio(i_dates, i_companies) = aBenchmark(i_dates, i_companies) * equipond_coeff;
    end
    portfolio_value(1, i_dates) = sum(portfolio(i_dates, :));
end

benchVal = portfolio_value';

benchRet = benchVal - lagmatrix(benchVal,1);
benchRet = benchRet(2:end,:);

