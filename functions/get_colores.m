function c = get_colores()

color_set = 2;
switch color_set
    case 1
        colores = cbrewer('qual','Dark2',5);
        
        c.data = [0,0,0];
        c.model = colores(1,:);
        c.data_last_fix = colores(2:3,:);
        c.model_last_fix = colores(2:3,:);

    case 2
        colores = cbrewer('qual','Dark2',3);
        colores = colores([2,1,3],:);

        c.data = [0,0,0];
        c.model = colores(1,:);
        c.data_last_fix = colores(2:3,:);
        c.model_last_fix = colores(2:3,:);
end

