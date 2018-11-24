function [] = DisplayCointegrationCausality(aDicoCausality,aDicoCointegration)

printTabCoint = cell2table(aDicoCointegration);
printTabCausal = cell2table(aDicoCausality);

disp('--------------- Entreprises dont le prix des CDS et des CS sont cointégrés ---------------');
disp("     " + aDicoCointegration{1, 1} + "             " + aDicoCointegration{1, 2} + "             " + ...
    aDicoCointegration{1, 11} + "                 " + aDicoCointegration{1, 12} + ...
    "                     " + aDicoCointegration{1, 13});
disp([printTabCoint(2:end,1), printTabCoint(2:end, 2), printTabCoint(2:end, 11), printTabCoint(2:end, 12), printTabCoint(2:end, 13)]); 
disp('----------------------------------------------------------------------------------');

disp('----- Entreprises dont le prix des CDS et/ou des CS révÃ¨lent une causalité au sens de Granger -----');
disp("     " + aDicoCausality{1, 1} + "                " + aDicoCausality{1, 2} + "               " + ...
    aDicoCausality{1, 3} + "            " + aDicoCausality{1, 6} + ...
    "      " + aDicoCausality{1, 7} + "          " + aDicoCausality{1, 10});
disp([printTabCausal(2:end,1), printTabCausal(2:end, 2), printTabCausal(2:end, 3), printTabCausal(2:end, 6), printTabCausal(2:end, 7), printTabCausal(2:end, 10)]); 
disp('----------------------------------------------------------------------------------');

end

