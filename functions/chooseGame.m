function [ WII, KINECT ,nomMouv, keepMovingDown] = chooseGame( nomMouvs, pathToChoixJeu )
    % Default values
    WII = false;
    KINECT = false;
    up_init = 1;
    down_init = 2;
    left_init = 4;
    right_init = 3;
    first = true;
    keepMovingDown = true;
    
    % Lire les dernières options   
    choixJeuFile = 'ChoixJeu.txt';
    fid = fopen([pathToChoixJeu choixJeuFile]);
    if fid~=-1
        while ~feof(fid)
            t = fgetl(fid);
            idxT = strfind(t,',');
            if strcmp(t(1:idxT-1), 'WII')
                WII = str2double(t(idxT+1:end));
            elseif strcmp(t(1:idxT-1), 'KINECT')
                KINECT = str2double(t(idxT+1:end));
            elseif strcmp(t(1:idxT-1), 'UP')
                up_init = str2double(t(idxT+1:end));
            elseif strcmp(t(1:idxT-1), 'DOWN')
                down_init = str2double(t(idxT+1:end));
            elseif strcmp(t(1:idxT-1), 'RIGHT')
                right_init = str2double(t(idxT+1:end));
            elseif strcmp(t(1:idxT-1), 'LEFT')
                left_init = str2double(t(idxT+1:end));
            end
        end
        fclose(fid);
    end

    
    % Couleur des backgrounds (fort utile en debug)
    bgcolor = 'w';    
    
    %CHOSEGAME Summary of this function goes here
    %   Detailed explanation goes here
    f = figure('name', 'Game options', ...
               'MenuBar', 'None', ...
               'CloseRequestFcn', [], ...
               'color', 'w', ...
               'windowstyle','modal');
    fPos = get(f, 'position');
    xc = floor(fPos(3)/2);

    % Bouton de choix de jeu
    uicontrol('Style', 'text', ...
              'String', 'Choose the device(s)', ...
              'fontsize', 15, ...
              'position', [xc-125, fPos(4)-60 250 25 ], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center');
    checkWii = uicontrol('Style','checkbox',...
                   'String','Wii', ...
                   'value', WII, ...
                   'position', [xc-25-80 fPos(4)-100 50 25], ...
                   'fontsize', 15, ...
                   'backgroundcolor', bgcolor, ...
                   'callback', @clickWii);
    checkKinect = uicontrol('Style','checkbox',...
                   'String','Kinect', ...
                   'value', KINECT, ...
                   'position', [xc-40+80 fPos(4)-100 80 25], ...
                   'fontsize', 15, ...
                   'backgroundcolor', bgcolor, ...
                   'callback', @clickKinect);
    
   % Bouton sélectionneurs de controles
    uicontrol('Style', 'text', ...
              'String', 'Choose the controls', ...
              'fontsize', 15, ...
              'position', [xc-125, fPos(4)-170 250 25 ], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center');
          % GAUCHE
    uicontrol('style', 'text', ...
              'string', 'Left', ...
              'position', [xc-100-125 fPos(4)-200 200 20], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center', ...
              'fontsize', 12);
    pop1 = uicontrol('Style','popupmenu',...
                   'position', [xc-100-100 fPos(4)-220 150 15], ...
                   'backgroundcolor', bgcolor, ...
                   'horizontalalignment', 'center', ...
                   'callback', @makeSureAllDifferent);
          % DROITE
    uicontrol('style', 'text', ...
              'string', 'Right', ...
              'position', [xc-100+125 fPos(4)-200 200 20], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center', ...
              'fontsize', 12);
    pop2 = uicontrol('Style','popupmenu',...
                   'position', [xc-100+150 fPos(4)-220 150 15], ...
                   'backgroundcolor', bgcolor, ...
                   'horizontalalignment', 'center', ...
                   'callback', @makeSureAllDifferent);
          % TOURNER
    uicontrol('style', 'text', ...
              'string', 'Rotate', ...
              'position', [xc-100-125 fPos(4)-265 200 20], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center', ...
              'fontsize', 12);
    pop3 = uicontrol('Style','popupmenu',...
                   'position', [xc-100-100 fPos(4)-285 150 15], ...
                   'backgroundcolor', bgcolor, ...
                   'horizontalalignment', 'center', ...
                   'callback', @makeSureAllDifferent);
               % DESCENDRE
    uicontrol('style', 'text', ...
              'string', 'Move down', ...
              'position', [xc-100+125 fPos(4)-265 200 20], ...
              'backgroundcolor', bgcolor, ...
              'HorizontalAlignment', 'center', ...
              'fontsize', 12);
    pop4 = uicontrol('Style','popupmenu',...
                   'position', [xc-100+150 fPos(4)-285 150 15], ...
                   'backgroundcolor', bgcolor, ...
                   'horizontalalignment', 'center', ...
                   'callback', @makeSureAllDifferent);
               
    btn = uicontrol('style', 'pushbutton', ...
              'String', 'Accept', ...
              'backgroundcolor', bgcolor, ...
              'position', [xc-100, fPos(4)-370 200 35], ...
              'horizontalalignment', 'center', ...
              'fontsize', 13, ...
              'callback', @clickAccept);
    updatePopUp();

    function clickAccept(~,~)
        delete(f)
    end

    function clickWii(~, ~)
        WII = get(checkWii, 'Value');
        updatePopUp();
    end
    function clickKinect(~, ~)
        KINECT = get(checkKinect, 'Value');
        updatePopUp();
    end

    function makeSureAllDifferent(~,~)
        % Trouver ceux sélectionnés
        left = getString(pop1);
        right = getString(pop2);
        up = getString(pop3);
        down = getString(pop4);
        
        if      sum(strcmp(left, right)) || ...
                sum(strcmp(left, up)) || ...
                sum(strcmp(left, down)) || ...
                sum(strcmp(right, up)) || ...
                sum(strcmp(right, down)) || ...
                sum(strcmp(up, down))
            set(btn, 'string', 'Choose different controls', 'enable', 'off')
        else
            % Selectionner les noms moves et les mettres dans l'ordre
            % nomMouvs est dans l'ordre : 'uparrow', 'downarrow', 'rightarrow', 'leftarrow'
             % Trouver ceux sélectionnés
            nomMouv{4} = getString(pop1);
            nomMouv{3} = getString(pop2);
            nomMouv{1} = getString(pop3);
            nomMouv{2} = getString(pop4);
            set(btn, 'string', 'Accept', 'enable', 'on')
        end
    end

    function updatePopUp
        if ~first
            % Trouver ceux sélectionnés
            left = getString(pop1);
            right = getString(pop2);
            up = getString(pop3);
            down = getString(pop4);
        end
        
        % Trouver quels garder
        toKeep = find([true WII KINECT]); % true car le clavier peut toujours marcher
        name = [nomMouvs{toKeep}]; %#ok<FNDSB>
        
        % Trouver (s'il existe encore) le nom qui avait été prélablement sélectionné
        if ~first
            left = findValInString(name, left);
            right = findValInString(name, right);
            up = findValInString(name, up);
            down = findValInString(name, down);
        else
            first = false;
            left = left_init;
            right = right_init;
            up = up_init;
            down = down_init;
        end
        
        % Mettre les nouveaux noms 
        set(pop1, 'string', name, 'value', left);
        set(pop2, 'string', name, 'value', right);
        set(pop3, 'string', name, 'value', up);
        set(pop4, 'string', name, 'value', down);
        makeSureAllDifferent();
    end

    function v = findValInString(s, sToFind)
        v = find(strcmp(s, sToFind));
        if isempty(v)
            v = 1;
        end
    end

    function s = getString(h)
        s = get(h, 'string');
        s = s{get(h, 'value')};
    end
    
    waitfor(f);

    
    % Écrire les nouvelles options
    if ~exist(pathToChoixJeu, 'dir')
        mkdir(pathToChoixJeu)
    end
    fid = fopen([pathToChoixJeu choixJeuFile], 'w+');
    fprintf(fid, 'WII,%d\n', WII);
    fprintf(fid, 'KINECT,%d\n', KINECT);
    fprintf(fid, 'UP,%d\n', findValInString(name, nomMouv{1}));
    fprintf(fid, 'DOWN,%d\n', findValInString(name, nomMouv{2}));
    fprintf(fid, 'LEFT,%d\n', findValInString(name, nomMouv{4}));
    fprintf(fid, 'RIGHT,%d\n', findValInString(name, nomMouv{3}));
    fclose(fid);
   

    
end

