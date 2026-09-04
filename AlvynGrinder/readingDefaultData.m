function [OuptutData, TrainData, TestData] = readingDefaultData()
    % Inconel
    location = 'defaultFolder';
    fileNameInconel = 'Inconel.xlsx';
    fileNameAluminum = 'Aluminum.xlsx';
    fileNameSteel = 'Steel.xlsx';
    defaultFolder = fullfile(pwd, location);

    fileInconel = fullfile(defaultFolder, fileNameInconel);
    fileAluminum = fullfile(defaultFolder, fileNameAluminum);
    fileSteel = fullfile(defaultFolder, fileNameSteel);
    
    inputTableAllData_Incoel = readtable(fileInconel);
    inputTableAllData_Aluminum = readtable(fileAluminum);
    inputTableAllData_Steel = readtable(fileSteel);


    



    OuptutData = [inputTableAllData_Incoel; ...
                  inputTableAllData_Aluminum; ...
                  inputTableAllData_Steel];

    % ---------------------------------------------------------------------
    cv = cvpartition(size(OuptutData,1),'HoldOut',0.15);
    idx = cv.test;
    TrainData = OuptutData(~idx,:);
    TestData  = OuptutData(idx,:);

    clear location;
    clear fileNameInconel;
    clear fileNameAluminum;
    clear fileNameSteel;
    clear defaultFolder;
    clear fileInconel;
    clear fileAluminum;
    clear fileSteel;
    clear inputTableAllData_Incoel;
    clear inputTableAllData_Aluminum;
    clear inputTableAllData_Steel;


end