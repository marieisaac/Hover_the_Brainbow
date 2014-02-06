%------------------------------------------------------------------------%
%		       Hover the Brainbow: 										 %
%		A Brainbow Image Processing Software                             %
%                                                                        %
%       Created by Yann Le Franc                                         %
%                                                                        %
%       Version 2.0: 05/02/2014                                        	 %
%                                                                        %
%	This work is licensed under the Creative Commons Attribution 3.0 	 %
%	Unported License. To view a copy of this license, visit 			 %
%	http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 	 %
%	Creative Commons, 444 Castro Street, Suite 900, Mountain View, 		 %
%	California, 94041, USA.												 %
%																		 %
%	For questions, suggestions and comments regarding the interface 	 %
%	and the data format, please contact Y. Le Franc 					 %
%	(ylefranc(at)gmail.com).         				                     %
%                                                                        %
% 																		 %
%------------------------------------------------------------------------%


function varargout = bips(varargin)
%------------------------------------------------------------------------%
% Initialization before creating the interface
%------------------------------------------------------------------------%

close all;
clear all;

%------------------------------------------------------------------------%
% Construct the graphical interface
%------------------------------------------------------------------------%

fh=figure; 
scrsz=get(0, 'Screensize');
set(fh, 'Name', 'Over the Brainbow', 'Toolbar', 'figure', 'Position', [1 1 scrsz(3)*0.7 scrsz(4)]);
set(fh, 'KeyPressFcn', @myShortKey);

%------------------------------------------------------------------------%
% Create panel containing the load buttons
%------------------------------------------------------------------------%

phload=uipanel('Parent', gcf, 'Title', 'Load Data', 'Position', [0.05 0.7 0.2 0.275]);

%------------------------------------------------------------------------%
% Create the buttons:                                                     
% 1- Load Raw Data: load the raw sequence of images
% 2- Load "Visualization" Data: load the modified stack after contrast and
% gamma enhancement in another software
% 3- Load Extracted Data file: load the saved structure corresponding to
% particular image sequence to continue the data extraction
%------------------------------------------------------------------------%

pbhraw=uicontrol(phload, 'Style', 'pushbutton', 'String', 'Load Raw Data', 'Units', 'normalized', 'Position',[0.05, 0.7, 0.9, 0.25], 'Callback', @LoadRawData);
pbhmod=uicontrol(phload, 'Style', 'pushbutton', 'String', 'Load Modified Data', 'Units', 'normalized', 'Position',[0.05, 0.4, 0.9, 0.25], 'Callback', @LoadModData);
pbhana=uicontrol(phload, 'Style', 'pushbutton', 'String', 'Continue Data Extraction', 'Units', 'normalized', 'Position',[0.05, 0.1, 0.9, 0.25], 'Callback', @LoadExtData);

%------------------------------------------------------------------------%
% Create panel containing the action buttons 
%------------------------------------------------------------------------%

phanalyse=uipanel('Parent', gcf, 'Title', 'Data Extraction','Position', [0.05 0.175 0.2 0.5]);

%------------------------------------------------------------------------%
% Create button for data extraction
% 1- New Cell: point with the mouse and select the cell of interest. The
% selected pixel will be used to label the cell. For the first cell
% selection, the data structure storing all the information to be saved will
% be created.CANNOT CREATE A NEW CELL IF CELL HAS NOT BEEN
% SAVED
% 2- Remove Cell
% 3- Create ROI: create a freehand roi to select the area of interest. Once
% the ROI is selected, the corresponding mask  is created in a temporary
% variable. If the button is pressed again to create another ROI the mask
% will incoroporated in the full image mask. The following data will be
% saved in the structure: ROI number, image nb, mask, selected pixel
% coordinates, selected pixel RGB value, ROI coordinates.
% 3- Delete ROI: in case the ROI is not good, allow to remove the ROI from
% the data structure and discard the mask
% 4- Save Cell: Stop the acquisition of ROI and allow to create a new cell. 
% 5- Export Data: Save the data structure in a mat file.
%------------------------------------------------------------------------%

pbhnew=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'New Cell (n)', 'Units', 'normalized', 'Position',[0.05, 0.85, 0.9, 0.12], 'Callback', @NewCell);
pbhremcell=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Delete Current Cell (c)', 'Units', 'normalized', 'Position',[0.05, 0.72, 0.9, 0.12], 'Callback', @RemoveCell);
pbhroi=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Create ROI (r)', 'Units', 'normalized', 'Position',[0.05, 0.59, 0.9, 0.12], 'Callback', @CreateROI);
pbhrem=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Delete Current ROI (d)', 'Units', 'normalized', 'Position',[0.05, 0.46, 0.9, 0.12], 'Callback', @RemoveROI);
pbhsave=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Save Cell (s)', 'Units', 'normalized', 'Position',[0.05, 0.34, 0.9, 0.12], 'Callback', @SaveCell);
pbhexp=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Export Data (e)', 'Units', 'normalized', 'Position',[0.05, 0.21, 0.9, 0.12], 'Callback', @ExportData);

%------------------------------------------------------------------------%
% Select Cell/ROI on the image and delete
% To be implemented in next version
% pbhselec=uicontrol(phanalyse, 'Style', 'pushbutton', 'String', 'Delete Selected Cell/ROI (t)', 'Units', 'normalized', 'Position',[0.05, 0.08, 0.9, 0.12], 'Callback', @DeleteSelect);
%------------------------------------------------------------------------%

%------------------------------------------------------------------------%
% Show plot of data extracted
%------------------------------------------------------------------------%

phvisu=uipanel('Parent', gcf, 'Title', 'Data Visualization','Position', [0.05 0.05 0.2 0.10]);
pbhnew=uicontrol(phvisu, 'Style', 'pushbutton', 'String', 'Show plots', 'Units', 'normalized', 'Position',[0.05, 0.05, 0.9, 0.75], 'Callback', @VisuInterface);

ah=axes('Parent', fh, 'Visible', 'off', 'Position', [0.275, 0.05, 0.7, 0.9]);

%------------------------------------------------------------------------%
% Create the slider to navigate through the stack
%------------------------------------------------------------------------%

slh=uicontrol(gcf, 'Style', 'slider', 'Min', 1, 'Max', 100, 'Value', 1, 'SliderStep', [0.1 1], 'Units', 'normalized', 'Position', [0.275, 0.015, 0.7, 0.025], 'Callback', @Move_stack); 

%------------------------------------------------------------------------%
% Callbacks functions
%------------------------------------------------------------------------%

setappdata(fh, 'ROInumber', 0);
set(pbhroi, 'UserData', 1);
setappdata(fh, 'Zoomon',0);
setappdata(fh, 'PrevImage', 1);
setappdata(fh, 'MoveDirection', 0);

%------------------------------------------------------------------------%
% Load raw data and store it into a unique 4D matrix
%------------------------------------------------------------------------%

    function LoadRawData(hObject, eventdata)
        
        global sequenceraw; 
        
        dirpat=uigetdir; 
        filext='*.tif';
        dirOutput=dir(fullfile(dirpat, filext)); 
        filenames={dirOutput.name};

        %load first image
        sequenceraw=imread(fullfile(dirpat, filenames{1}));

        %store file information for fast retrieval and loading

        setappdata(fh, 'myrawpath', dirpat); %store file path as internal variable of the GUI
        setappdata(fh, 'myrawfiles', filenames); %store structure containing file names as internal variable of the GUI
        
        numFrame=numel(filenames); % get the number of File
        set(pbhraw, 'UserData', numFrame); %Store the number of file as variable attached to the button loading the raw data

        sprintf 'Loading complete'

    end

%------------------------------------------------------------------------%
% Load pretreated data
%------------------------------------------------------------------------%

    function LoadModData(hObject, eventdata)
        
        global sequencemod;
        
        dirpat=uigetdir; 
        filext='*.tif';
        dirOutput=dir(fullfile(dirpat, filext)); 
        filenames={dirOutput.name};

        sequencemod=imread(fullfile(dirpat, filenames{1}));
        axes(ah); 
        image(sequencemod);
        axis off;

        %Store file information as internal variable of the GUI 
        
        setappdata(fh, 'mymodpath', dirpat);

        setappdata(fh, 'mymodfiles', filenames);
        numFrame=numel(filenames);

        set(pbhmod, 'UserData', numFrame);

        %Store visualization information as internal variable of the GUI
        newXLim = get(ah,'XLim');
        newYLim = get(ah, 'YLim');

        setappdata(fh,'newXLim',newXLim);
        setappdata(fh, 'newYLim',newYLim);
    
        set(ah, 'UserData', 1);
        set(pbhnew, 'UserData', 0);

        sprintf 'Loading complete'
        
        set(slh, 'Max', numFrame, 'SliderStep', [(1/(numFrame-1)) (1/(numFrame-1))]);
                
        cmap=colormap
        size(cmap)
        
    end

%------------------------------------------------------------------------%
% Load data structure to continue the analysis
%------------------------------------------------------------------------%

    function LoadExtData(hObject, eventdata)
        
        global sequenceraw;
        global sequencemod;
        
        newXLim = get(ah,'XLim');
        newYLim = get(ah, 'YLim');
        
        setappdata(fh,'newXLim',newXLim);
        setappdata(fh, 'newYLim',newYLim);

        LoadExtFlag=1;
        setappdata(fh, 'LoadExtFlag', LoadExtFlag);
        
        zoomon=getappdata(fh, 'Zoomon');
        %Choose analysis file
        
        [filname, pathfile]=uigetfile('*.mat');
        
        global extdata
        
        filpath=[pathfile, filname];
        
        extdata=load(filpath, '-mat');
        
        disp ('Import marche')
        
        %Import modified data
        
        dirpat2=extdata.ModData
        filext='*.tif';
        dirOutput2=dir(fullfile(dirpat2, filext))
        filenames={dirOutput2.name}
        
        if (size(filenames)==[0 0])
            
            dirpat2=uigetdir('Select display data folder'); 
            filext='*.tif';
            dirOutput2=dir(fullfile(dirpat2, filext)); 
            filenames={dirOutput2.name};

        end
        
        setappdata(fh, 'mymodfiles', filenames);
        setappdata(fh, 'mymodpath', dirpat2);
        numFrame=numel(filenames);

        sequencemod=imread(fullfile(dirpat2, filenames{1}));
        set(pbhmod, 'UserData', numFrame);
        axes(ah); 
        image(sequencemod);
        axis off;

        set(slh, 'Max', numFrame, 'SliderStep', [(1/(numFrame-1)) (1/(numFrame-1))]);
        
        %Import Raw data

        dirpat3=extdata.RawData;
        filext='*.tif';
        dirOutput3=dir(fullfile(dirpat3, filext)); 
        filenames={dirOutput3.name};

        if (size(filenames)==[0 0])
            
            dirpat3=uigetdir('Select Raw data folder'); 
            filext='*.tif';
            dirOutput3=dir(fullfile(dirpat3, filext)); 
            filenames={dirOutput3.name};

        end

        setappdata(fh, 'myrawfiles', filenames);
        numFrame=numel(filenames);

        sequenceraw=imread(fullfile(dirpat3, filenames{1}));    
        
        setappdata(fh, 'myrawpath', dirpat3);
        sprintf 'Loading complete'
        
        %SET NBCELLS AND INITIALIZE OTHER VARIABLES
        nbcell=size(extdata.Cell, 2);
        set(pbhnew, 'UserData', nbcell);       

        UpdateImageInfo();

        axis off;
        axes(ah);
        

    end

%------------------------------------------------------------------------%
% Navigate through the stack with the slider
%------------------------------------------------------------------------%

    function Move_stack(hObject, eventdata, handle, sequencemod)
        
        global sequencemod;
        
        newXLim = get(ah,'XLim');
        newYLim = get(ah, 'YLim');

        setappdata(fh,'newXLim',newXLim);
        setappdata(fh, 'newYLim',newYLim);

        set(ah, 'XLim',newXLim, 'YLim', newYLim);
        
        imagenb = get(slh,'Value');
        numFrame = get(pbhmod, 'UserData');
        
        MovDir=getappdata(fh, 'MoveDirection');
        
        if (MovDir==0)
            %Initial condition. No mouvement before
            
            previmage=getappdata(fh, 'PrevImage'); %Should be 1
            MovDir=imagenb-previmage;
            
            setappdata(fh, 'MoveDirection', MovDir);
            setappdata(fh, 'PrevImage', imagenb);
            
        else
            
            previmage= getappdata(fh, 'PrevImage');
            MovDir=imagenb-previmage;
            
%            disp(['Previous image is :', num2str(previmage)])
%            disp(['Direction is: ', num2str(MovDir)])
        
            setappdata(fh, 'PrevImage', imagenb);
            setappdata(fh, 'MoveDirection', MovDir);
            
        end
        
        if (imagenb<=0 || imagenb>numFrame)
            
            hwarn=msgbox('You are one end of the stack', 'StackBoundaryWarning', 'warn');
            
        else
            
        numFrame=get(pbhmod, 'UserData');
        newXLim=getappdata(fh,'newXLim');
        newYLim=getappdata(fh,'newYLim');
        zoomon=getappdata(fh, 'Zoomon'); 
        
        dirpath=getappdata(fh, 'mymodpath');
        filenames=getappdata(fh, 'mymodfiles');
        
        axes(ah);
        test=fullfile(dirpath, filenames{imagenb})
        sequencemod=imread(fullfile(dirpath, filenames{imagenb}));
        image(sequencemod);

        refreshdata(ah); 
        set(ah, 'XLim',newXLim, 'YLim', newYLim);
        axis off; 
        
        drawnow;
        
        axis off;
        set(ah, 'XLim',newXLim, 'YLim', newYLim);

        axes(ah);
        UpdateImageInfo();
        
        set(gca, 'UserData', imagenb);
        end
    end

%------------------------------------------------------------------------%
% Select a new Cell and create a new entry in the data structure
%------------------------------------------------------------------------%

    function NewCell(hObject, eventdata, handle)
        
        zoom off;
        
        nbcell=get(pbhnew, 'UserData'); %Get the number of the cell
        celltick=get(pbhroi, 'UserData'); %Get the flag cell currently created or not
        
        if (celltick==1) %If cell is not under creation 
            
            [xval yval]=ginput(1); %get position of the mouse pointer on the image

            if (nbcell==0) %If this is the first cell created
                
                %Prepare variables that will be added to the data structure
                
                rawpath=getappdata(fh, 'myrawpath'); %Path to the raw files
                modpath=getappdata(fh, 'mymodpath'); %Path to the modified files
                imagenb = get(slh,'Value'); %Image number (position in the stack)
                numframe=get(pbhmod, 'UserData'); %Total number of images in the stack

                c=clock; %Get time and date

                nbcell=nbcell+1; %Add a new cell to the cell count
                %disp(['NBcell=',num2str(nbcell)])
                label=int2str(nbcell); %Transform the cell number into string for print out
                
                text(xval, yval,label); %Print out on the graph the number of the cell
                
                global extdata; %Create an instance of data structure
                
                %Specifies the whole data structure with the fieldname and
                %the type of data.
                
                extdata=struct('Created',c, 'Modified', c, 'RawData', rawpath, 'ModData', modpath, 'Cell', struct('CellNumber', nbcell, 'LabelXY', [xval, yval], 'ROI', struct('ImageNumber',imagenb, 'Mask', [], 'PixelList', [], 'PixelValues', [], 'ROIXY', [])), 'ImageMetadata', struct('CellNumber', nbcell, 'LabelXY', [], 'ROIXY', {}));
                
                %Initialize the image metadata structure: set all values to
                %0 for the whole stack
                
                for i=1:numframe 
                
                    extdata.ImageMetadata(1,i).CellNumber(1,nbcell)=0;
                    extdata.ImageMetadata(1,i).LabelXY(nbcell,1)=0;
                    extdata.ImageMetadata(1,i).LabelXY(nbcell,2)=0;
                end
                
                %Enter the values for the new cell added in the Image
                %Metdata structure
                extdata.ImageMetadata(1,imagenb).CellNumber(1,nbcell)=nbcell;
                extdata.ImageMetadata(1,imagenb).LabelXY(nbcell,1)=xval;
                extdata.ImageMetadata(1,imagenb).LabelXY(nbcell,2)=yval;

                %Create the new Cell structure to store all information
                %regarding this cell. First information: Cell number and
                %position of the label on the screen
                
                extdata.Cell(1,nbcell).CellNumber=nbcell;
                extdata.Cell(1,nbcell).LabelXY=[xval yval];
                
                %Store new values: update
                set(pbhnew, 'UserData', nbcell);
                testnbcell=get(pbhnew, 'UserData');
                set(pbhroi, 'UserData',0);
                
                %Initialize the number of ROIs existing for this cell
                setappdata(fh, 'ROInumber', 0);


            else %if the new cell is not the first
                             
                imagenb = get(slh,'Value'); %get the position in the stack
                
                global extdata; %call the data structure to be updated
                
                nbcell=nbcell+1; %increment cell number
                
                label=int2str(nbcell); %convert cell number into string
                text(xval, yval,label); %print out the cell number on the graph
                
                
                if (size(extdata.ImageMetadata(1,imagenb).CellNumber)==[1 1])
                    %If the size of the array storing the cell numbers
                    %created in each image is of one (only one value in the
                    %array).
                    
                    if (extdata.ImageMetadata(1, imagenb).CellNumber(1,1)==0)
                    
                        %If the value of the unique point in the array is
                        %zero => The array has not been modified since its
                        %initialization during the creation of the first
                        %cell
                        
                        tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);
                        %Store the indice used to update the array based on
                        %the size the initial array here size is one
                        %because size array is [1 1].
                        
                    else %if the value is not zero. A first cell has been created in this image
                    
                        tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;
                        %Store the indice used to update the array. As the
                        %value is not zero, we need to add a new cell in
                        %the array therefore we increment the size by one.
                    end
                    
                else %if the size is not [1 1] 

                tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;
                %Store indice used to update the array. Here add one new
                % entry.
                
                end
                
                %Update the data structure for the image Metadata
                
                extdata.ImageMetadata(1,imagenb).CellNumber(1,tmpex)=nbcell;
                extdata.ImageMetadata(1,imagenb).LabelXY(tmpex,1)=xval;
                extdata.ImageMetadata(1,imagenb).LabelXY(tmpex,2)=yval;

                %Update the data structure: create a new cell
                
                extdata.Cell(1,nbcell).CellNumber=nbcell;
                extdata.Cell(1,nbcell).LabelXY=[xval yval];
                
                %Update values stored in the graphic interface
                set(pbhnew, 'UserData', nbcell);
                set(pbhroi, 'UserData',0);
                
                %Initialize the number of roi for the cell to zero
                roiinit=0;
                setappdata(fh, 'ROInumber', roiinit);
                testROInum=getappdata(fh, 'ROInumber');
                

            end
            
            
        else %if the flag is zero: a cell is currently being created.
            
            disp('A cell is currently under construction. Please Save the cell if you are finished with it.')
        end
    end

%------------------------------------------------------------------------%
% Create ROIs
%------------------------------------------------------------------------%

    function CreateROI(hObject, eventdata, handle, extdata, sequenceraw)

        %Call datastructure and data
        global extdata;
        global sequenceraw;
        
        %If first time ROI therefore =1 as set in the LoadModData function.
        %Is this value updated somewhere?
      
        imagenbrois=get(gca,'UserData');
        
        %Get the number of ROI created for this particular cell.
        roicounter=getappdata(gcf, 'ROInumber');
        
        %Create a FreeHand selection to create ROI.
        
        ro1=imfreehand(gca);
        setClosed(ro1, 'True');
        
        %Get the cell number
        nbcell=get(pbhnew, 'UserData');
        
        %Get the image number or position in the stack
        imagenb = get(slh,'Value');
    
        %Store the current image using the current position in the stack.
        %CurImage=sequenceraw(:,:,:,imagenbrois);
        dirpath=getappdata(fh, 'myrawpath');
        filenames=getappdata(fh, 'myrawfiles');        
        sequenceraw=imread(fullfile(dirpath, filenames{imagenb}));
        
        CurImage=sequenceraw;
        
        %If there are no roi associated with this cell
        if (roicounter==0)
            
            roicounter=1; %Add a new ROI to the count
            setappdata(gcf, 'ROInumber', roicounter); %Update the stored value
            
            pos1=getPosition(ro1); %Get the position of the ROI: X-Y Coordinate of each points defining the ROI
            
            %Store info in the data structure for Cells: current image number and ROI position 
        
            extdata.Cell(1,nbcell).ROI(1,roicounter).ImageNumber=imagenb;
            extdata.Cell(1,nbcell).ROI(1,roicounter).ROIXY=pos1;
            
            %Check the information for this particular imagenb. Is there a
            %cell already? Is this still the same=> Need to add a NEW
            
            
            if (size(extdata.ImageMetadata(1,imagenb).CellNumber)==[1 1]) 
                %If size one meaning either no cell or only one.
                if (extdata.ImageMetadata(1, imagenb).CellNumber(1,1)==0)
                   %If value is zero meaning zero cells
                    tmpex2=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);

                elseif (extdata.ImageMetadata(1, imagenb).CellNumber(1,1)==nbcell)
                   %IF value is nbcell, meaning if there is one cell in the
                   %image that corresponds to the current cell

                    tmpex2=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);
                
                else %if none if these two conditions apply then increment to create a new one
                    
                    tmpex2=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;                    
                    
                end

            elseif (extdata.ImageMetadata(1, imagenb).CellNumber(1, size(extdata.ImageMetadata(1, imagenb).CellNumber, 2))~=nbcell)
            %If the 
            tmpex2=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;
            
            else 
                
                tmpex2=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);
                
            end
            
              %Get the size of the current Image Metadata based on the size
              %of the cell number stored to associate the ROI XY positions
              %If there is only one cell therefore is equal to 1.
                         
            %Store the XY Coordinates of the points defining the ROI in a
            %cell of a cell array at the indice corresponding to the cell
            %number.
            
            extdata.ImageMetadata(1,imagenb).ROIXY{tmpex2,1}=pos1;
            
            extdata.ImageMetadata(1,imagenb).CellNumber(1,tmpex2)=nbcell;           
            labelspval=extdata.Cell(1,nbcell).LabelXY
            extdata.ImageMetadata(1,imagenb).LabelXY(tmpex2, 1)=labelspval(1,1);
            extdata.ImageMetadata(1,imagenb).LabelXY(tmpex2, 2)=labelspval(1,2);
           
            %Create and store a black and white mask
            testMask=createMask(ro1);
            
            %Test if the Mask is empty before going any further. If it is
            %empty something is wrong with the ROI shape. Therefore, after 
            %a warning message it proposes to create it allover again. 
            %After recreating the ROI, it tests if the problem still exists. 
            %If so it create another warning message proposing to continue
            %the ROI creation and then delete the ROI
            
            if (size(testMask)==[0 0]) 
                hwarn=msgbox('You created an empty ROI!! Please redo it', 'BadROIWarning', 'warn'); 
                ro1=imfreehand(gca);
                setClosed(ro1, 'True');
            
                testMask=createMask(ro1);
                
                if (size(testMask)==[0 0])
                    hwarn=msgbox('You created an empty ROI AGAIN!! Something is wrong. Please DELETE THE CURRENT ROI and start the process again', 'SecondBadROIWarning', 'warn'); 
                end
            else
                
                extdata.Cell(1,nbcell).ROI(1,roicounter).Mask=testMask;
            
            end
            
            %Extract the XY information of the pixels included in the ROI
            %using the B&W Mask created.
            PixList=regionprops(testMask, 'PixelList');
            
            %Check if there are more than one ROI. If not then store the
            %values in the Cell data structure.
            sizeList=size(PixList);
          
            if (sizeList==[1 1])
                PixXY=PixList(1).PixelList;
                extdata.Cell(1,nbcell).ROI(1,roicounter).PixelList=PixXY;
            elseif (sizeList==[2,1])
                PixXY=PixList(1).PixelList;
                extdata.Cell(1,nbcell).ROI(1,roicounter).PixelList=PixXY;                  
            else 
                disp('Error: More than one identified ROI')
            end
            
            %Get the pixel values for all the pixels included in the ROI
            % To get the 3 channels values (RGB), you need to use the
            % impixel function
            
            %Get the size of the pixel List
            size(PixXY);
            %Create a vector containing all the X values of the pixel list
            xval=PixXY(:,1);
            size(xval);
            %Create a vector containing all the Y values of the pixel list
            yval=PixXY(:,2);
            size(yval);
            
            %Get the pixel values for RGB in an array from the raw image
            PixVal=impixel(CurImage, xval, yval);
            %Store the pixel values in the Cell Data structure
            extdata.Cell(1,nbcell).ROI(1,roicounter).PixelValues=PixVal;
            
            %Insert here extract Centroid X, Y
                      
        else %If this not the first ROI of the current cell
            
            disp('Thats more than one ROI')
            
            %Increment and update the roi counter
            roicounter=roicounter+1;
            setappdata(gcf, 'ROInumber', roicounter);
            
            %Store information in the Cell data structure
            
            %extdata.Cell(1,nbcell).ROI(1,roicounter).ImageNumber=imagenbrois;
            extdata.Cell(1,nbcell).ROI(1,roicounter).ImageNumber=imagenb;
            
            %Get the position of the ROI: X-Y Coordinate of each points defining the ROI
            pos1=getPosition(ro1);
            
            extdata.Cell(1,nbcell).ROI(1,roicounter).ROIXY=pos1;
            
                if (size(extdata.ImageMetadata(1,imagenb).CellNumber)==[1 1])% && 
                    
                    if (extdata.ImageMetadata(1, imagenb).CellNumber(1,1)==0)
                    
                        tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);

                    elseif (extdata.ImageMetadata(1, imagenb).CellNumber(1,1)==nbcell)
                           %IF value is nbcell, meaning if there is one cell in the
                           %image that corresponds to the current cell

                         tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);
                    
                    else
                    
                        tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;
                    end
                    
            elseif (extdata.ImageMetadata(1, imagenb).CellNumber(1, size(extdata.ImageMetadata(1, imagenb).CellNumber, 2))~=nbcell)
            %If the 
              tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2)+1;
            
            else 
                
                tmpex=size(extdata.ImageMetadata(1,imagenb).CellNumber, 2);
                
            end
            
            extdata.ImageMetadata(1,imagenb).ROIXY{tmpex,1}=pos1;

            extdata.ImageMetadata(1,imagenb).CellNumber(1,tmpex)=nbcell;           
            labelspval=extdata.Cell(1,nbcell).LabelXY;
            extdata.ImageMetadata(1,imagenb).LabelXY(tmpex, 1)=labelspval(1,1);
            extdata.ImageMetadata(1,imagenb).LabelXY(tmpex, 2)=labelspval(1,2);

            testMask=createMask(ro1);
                        %Test if the Mask is empty before going any further. If it is
            %empty something is wrong with the ROI shape. Therefore, after 
            %a warning message it proposes to create it allover again. 
            %After recreating the ROI, it tests if the problem still exists. 
            %If so it create another warning message proposing to continue
            %the ROI creation and then delete the ROI
            
            if (size(testMask)==[0 0]) 
                hwarn=msgbox('You created an empty ROI!! Please redo it', 'BadROIWarning', 'warn'); 
                ro1=imfreehand(gca);
                setClosed(ro1, 'True');
            
                testMask=createMask(ro1);
                
                if (size(testMask)==[0 0])
                    hwarn=msgbox('You created an empty ROI AGAIN!! Something is wrong. Please DELETE THE CURRENT ROI and start the process again', 'SecondBadROIWarning', 'warn'); 
                end
            else
                
                extdata.Cell(1,nbcell).ROI(1,roicounter).Mask=testMask;
            
            end

            PixList=regionprops(testMask, 'PixelList');
            sizeList=size(PixList);
            if (sizeList==[1 1])
                PixXY=PixList(1).PixelList;
                extdata.Cell(1,nbcell).ROI(1,roicounter).PixelList=PixXY;
            elseif (sizeList==[2,1])
                PixXY=PixList(1).PixelList;
                extdata.Cell(1,nbcell).ROI(1,roicounter).PixelList=PixXY;
                
            else 
                disp('Error: More than one identified ROI')
            end
            
            size(PixXY);
            xval=PixXY(:,1);
            size(xval);
            yval=PixXY(:,2);
            size(yval);
            PixVal=impixel(CurImage, xval, yval);
            extdata.Cell(1,nbcell).ROI(1,roicounter).PixelValues=PixVal;
       
        end
        
    end

%------------------------------------------------------------------------%
% Save cell
%------------------------------------------------------------------------%

    function SaveCell(hObject, eventdata)
        
        set(pbhroi, 'UserData', 1);
        
    end
 
%------------------------------------------------------------------------%
% Remove Cell
%------------------------------------------------------------------------%

    function RemoveCell(extdata, hObject, eventdata)
        
        global extdata;
        
        imagenb=get(gca,'UserData')
        nbcell=get(pbhnew, 'UserData')
        
        extdata.Cell(nbcell)=[];
        
        if (size(extdata.ImageMetadata(imagenb).CellNumber,2)==1)

            extdata.ImageMetadata(imagenb).CellNumber=[0];
            extdata.ImageMetadata(imagenb).LabelXY=[0, 0];
            extdata.ImageMetadata(imagenb).ROIXY=[];

        else
            
            extdata.ImageMetadata(imagenb).CellNumber=extdata.ImageMetadata(imagenb).CellNumber(1, 1:size(extdata.ImageMetadata(imagenb).CellNumber,2)-1);
            extdata.ImageMetadata(imagenb).LabelXY=extdata.ImageMetadata(imagenb).LabelXY(1:(size(extdata.ImageMetadata(imagenb).LabelXY,1)-1), :);
        
        end

        nbcell=nbcell-1
        set(pbhnew, 'UserData',nbcell);
        UpdateImageInfo();
        hwarn=msgbox('You deleted the latest created cell. If you press again you will also delete the previously created cell', 'RemoveCellWarning', 'warn'); 
        
    end

%------------------------------------------------------------------------%
% Remove ROI
%------------------------------------------------------------------------%

    function RemoveROI(extdata, hObject, eventdata)
%       

        global extdata;
        
        imagenb=get(gca,'UserData')
        roicounter=getappdata(gcf, 'ROInumber')
        nbcell=get(pbhnew, 'UserData')
        SizeBefore=size(extdata.Cell(nbcell).ROI, 2)
        
        extdata.Cell(nbcell).ROI(roicounter)=[];
        roicounter=roicounter-1;
        setappdata(gcf, 'ROInumber', roicounter);
        
        if (size(extdata.ImageMetadata(imagenb).CellNumber,2)==1)

            extdata.ImageMetadata(imagenb).CellNumber=[0];
            extdata.ImageMetadata(imagenb).LabelXY=[0, 0];
            extdata.ImageMetadata(imagenb).ROIXY=[];

        else
            
            extdata.ImageMetadata(imagenb).CellNumber=extdata.ImageMetadata(imagenb).CellNumber(1, 1:size(extdata.ImageMetadata(imagenb).CellNumber,2)-1);
            extdata.ImageMetadata(imagenb).LabelXY=extdata.ImageMetadata(imagenb).LabelXY(1:(size(extdata.ImageMetadata(imagenb).LabelXY,1)-1), :);
            extdata.ImageMetadata(imagenb).ROIXY=extdata.ImageMetadata(imagenb).ROIXY(1:size(extdata.ImageMetadata(imagenb).ROIXY,1)-1, 1);
        
        end
        
        UpdateImageInfo();
        SizeAfter=size(extdata.Cell(nbcell).ROI, 2);
        hwarn=msgbox('You deleted the latest created ROI. If you press again you will also delete the previously created ROI', 'RemoveROIWarning', 'warn'); 
       
    end

%------------------------------------------------------------------------%
% Show ROI and cell number
%------------------------------------------------------------------------%

    function UpdateImageInfo(hObject, eventdata, extdata)
        
        %Check if data has been reloaded from pre-existing data structure
        LoadExtFlag=getappdata(fh, 'LoadExtFlag');
        
        %Call the global variable containing the data structure
        global extdata;
        
        %Get the current position in the stack, i.e. the image number
        imagenb = get(slh, 'Value'); 
        
        %Get the celL number
        nbcell=get(pbhnew, 'UserData');
        
        %Get the zoom information

        newXLim=get(ah,'XLim');
        newYLim=get(ah,'YLim');

        MovDir=getappdata(fh, 'MoveDirection');

        %If the next image does not have yet a ROI defined associated with
        %a cell number
        
        if (nbcell>0)
            
            %If the current image (or position in the stack) is the
            %first of the stack
            if (imagenb==1) 
                
                %disp('First image of the stack')
                
                if(size(extdata.ImageMetadata(imagenb).CellNumber, 2)==1)
                    %If size cellnumber array is one: can be zero cell or
                    %one cell
                    
                    if (extdata.ImageMetadata(imagenb).CellNumber(1, 1)==0)
                        %if the value of the array is zero, meaning no
                        %cells then do nothing
                        
                        disp('Do Nothing: No Roi defined for the first image')
                    
                    else
                        %if the value is not zero, there is a cell that has
                        %to be shown then get cellnumber and label position
                                                
                        cellnumber=extdata.ImageMetadata(imagenb).CellNumber(1,1);
                        labelxy=extdata.ImageMetadata(imagenb).LabelXY(1, :);
                        roixy=extdata.ImageMetadata(imagenb).ROIXY{1, 1};
                        
                        if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)
                                                       
                            if ((1/labelxy(1, 1))>newXLim(1,1) && (1/labelxy(1, 1))<newXLim(1,2) && (1/labelxy(1, 2))>newYLim(1,1) && (1/labelxy(1, 2))<newYLim(1,2))
                                
                                hold on
                                label=int2str(cellnumber(1, 1));
                                xval=labelxy(1, 1);
                                yval=labelxy(1, 2);
                                text(xval, yval, label);
                                plot(roixy(:,1), roixy(:, 2), 'r');
                                hold off
                            end
                            
                        else
                            
                            if (labelxy(1, 1)>newXLim(1,1) && labelxy(1, 1)<newXLim(1,2) && labelxy(1, 2)>newYLim(1,1) && labelxy(1, 2)<newYLim(1,2))
                                
                                hold on
                                label=int2str(cellnumber(1, 1));
                                xval=labelxy(1, 1);
                                yval=labelxy(1, 2);
                                text(xval, yval, label);
                                plot(roixy(:,1), roixy(:, 2), 'r');
                                hold off
                            end
                            
                        end
                        
                    
                    end
                    
                else
                    %If size is larger than one, there are more than one
                    %cell to be shown
                    
                    cellnumber=extdata.ImageMetadata(imagenb).CellNumber(:,:);
                    labelxy=extdata.ImageMetadata(imagenb).LabelXY;
                    roixy=extdata.ImageMetadata(imagenb).ROIXY;

                    for i=1:size(cellnumber, 2)
                        
                        if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                            if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                hold on
                                label=int2str(cellnumber(1, i));
                                xval=labelxy(i, 1);
                                yval=labelxy(i, 2);
                                roi=roixy{i, 1};
                                
                                text(xval, yval, label);
                                plot(roi(:,1), roi(:, 2), 'r');
                                hold off
                                                           
                            end

                        else
                            
                            if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                hold on
                                label=int2str(cellnumber(1, i));
                                xval=labelxy(i, 1);
                                yval=labelxy(i, 2);
                                roi=roixy{i, 1};
                                                                
                                text(xval, yval, label);
                                plot(roi(:,1), roi(:, 2), 'r');
                                hold off

                            end

                        end
                    end
                end
                
            else
             %If this is not the first image of the stack

                if(size(extdata.ImageMetadata(imagenb).CellNumber, 2)==1)
                    %If the size for the current image is one: there can be
                    %either no cells or one
                    if (extdata.ImageMetadata(imagenb).CellNumber(1, 1)==0)
                        %if the value of the array is zero, meaning no
                        %cells then check if there are cells defined in the
                        %neighboring image, depending on the sense in the
                        %stack
                        disp('There is no cell created on that image')
                        
                        if (MovDir==1)
                                                       
                            if(size(extdata.ImageMetadata(imagenb-1).CellNumber, 2)==1)
                                %If the size of the cellnumber for the previous
                                %image then check its value
                                
                                if (extdata.ImageMetadata(imagenb-1).CellNumber(1, 1)==0)
                                %if the value of the array is zero, meaning no
                                %cells then do nothing

                                disp('Do Nothing: No Roi defined for the current and the previous image')

                                else
                                %if the value is not zero, there is a cell that has
                                %to be shown then get cellnumber and label position
                                
                                    cellnumber=extdata.ImageMetadata(imagenb-1).CellNumber(:,:);
                                    labelxy=extdata.ImageMetadata(imagenb-1).LabelXY;
                                    %roixy=extdata.ImageMetadata(imagenb-1).ROIXY;

                                    for i=1:size(cellnumber, 2)

                                        if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                                            if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                                hold on
                                                label=int2str(cellnumber(1, i));
                                                xval=labelxy(i, 1);
                                                yval=labelxy(i, 2);

                                                text(xval, yval, label);
                                                hold off

                                            end

                                        else
                                            if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                                hold on
                                                label=int2str(cellnumber(1, i));
                                                xval=labelxy(i, 1);
                                                yval=labelxy(i, 2);

                                                text(xval, yval, label);
                                                hold off

                                            end

                                        end
                                    end

                                end

                            else
                                %disp('There is more than one cell in the previous image')
                                cellnumber=extdata.ImageMetadata(imagenb-1).CellNumber(:,:);
                                labelxy=extdata.ImageMetadata(imagenb-1).LabelXY;

                                for i=1:size(cellnumber, 2)

                                    if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                                        if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                            hold on
                                            label=int2str(cellnumber(1, i));
                                            xval=labelxy(i, 1);
                                            yval=labelxy(i, 2);

                                            text(xval, yval, label);
                                            hold off
                                        end

                                    else
                                        if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                            hold on
                                            label=int2str(cellnumber(1, i));
                                            xval=labelxy(i, 1);
                                            yval=labelxy(i, 2);

                                            text(xval, yval, label);
                                            hold off
                                        end

                                    end
                                end

                            end
                            
                        elseif (MovDir==-1)

                            if(size(extdata.ImageMetadata(imagenb+1).CellNumber, 2)==1)
                                %If the size of the cellnumber for the previous
                                %image then check its value
                                
                                if (extdata.ImageMetadata(imagenb+1).CellNumber(1, 1)==0)
                                %if the value of the array is zero, meaning no
                                %cells then do nothing

                                    disp('Do Nothing: No Roi defined for the current and the next image')

                                else
                                %if the value is not zero, there is a cell that has
                                %to be shown then get cellnumber and label position
                                
                                    cellnumber=extdata.ImageMetadata(imagenb+1).CellNumber(:,:);
                                    labelxy=extdata.ImageMetadata(imagenb+1).LabelXY;

                                    for i=1:size(cellnumber, 2)

                                        if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                                            if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                                hold on
                                                label=int2str(cellnumber(1, i));
                                                xval=labelxy(i, 1);
                                                yval=labelxy(i, 2);
   
                                                text(xval, yval, label);
                                                hold off
                                            end

                                        else
                                            if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))
    
                                                hold on
                                                label=int2str(cellnumber(1, i));
                                                xval=labelxy(i, 1);
                                                yval=labelxy(i, 2);

                                                text(xval, yval, label);
                                                hold off

                                            end

                                        end
                                    end


                                end

                            else

                                cellnumber=extdata.ImageMetadata(imagenb+1).CellNumber(:,:);
                                labelxy=extdata.ImageMetadata(imagenb+1).LabelXY;

                                for i=1:size(cellnumber, 2)

                                    if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                                        if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                            hold on
                                            label=int2str(cellnumber(1, i));
                                            xval=labelxy(i, 1);
                                            yval=labelxy(i, 2);

                                            text(xval, yval, label);
                                            hold off
                                        end

                                    else
                                        if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                            hold on
                                            label=int2str(cellnumber(1, i));
                                            xval=labelxy(i, 1);
                                            yval=labelxy(i, 2);

                                            text(xval, yval, label);
                                            hold off

                                        end

                                    end
                                end


                            end
                            
                        end
                    else
                        
                        %if the value is not zero, there is a cell that has
                        %to be shown then get cellnumber and label position
                        
                        cellnumber=extdata.ImageMetadata(imagenb).CellNumber(:,:);
                        labelxy=extdata.ImageMetadata(imagenb).LabelXY;
                        roixy=extdata.ImageMetadata(imagenb).ROIXY;

                        for i=1:size(cellnumber, 2)

                            if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                                if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                    hold on
                                    label=int2str(cellnumber(1, i));
                                    xval=labelxy(i, 1);
                                    yval=labelxy(i, 2);
                                    roi=roixy{i, 1};

                                    text(xval, yval, label);
                                    plot(roi(:,1), roi(:, 2), 'r');
                                    hold off

                                end

                            else
                                if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                    hold on
                                    label=int2str(cellnumber(1, i));
                                    xval=labelxy(i, 1);
                                    yval=labelxy(i, 2);
                                    roi=roixy{i, 1};

                                    text(xval, yval, label);
                                    plot(roi(:,1), roi(:, 2), 'r');
                                    hold off

                                end

                            end
                        end
                        
                    
                    end
                else
                    cellnumber=extdata.ImageMetadata(imagenb).CellNumber(:,:);
                    labelxy=extdata.ImageMetadata(imagenb).LabelXY;
                    roixy=extdata.ImageMetadata(imagenb).ROIXY;

                    for i=1:size(cellnumber, 2)
                        
                        if (newXLim(1,1)==0 && newXLim(1,2)==1 && newYLim(1,1)==0 && newYLim(1,2)==1)

                            if ((1/labelxy(i, 1))>newXLim(1,1) && (1/labelxy(i, 1))<newXLim(1,2) && (1/labelxy(i, 2))>newYLim(1,1) && (1/labelxy(i, 2))<newYLim(1,2))

                                hold on
                                label=int2str(cellnumber(1, i));
                                xval=labelxy(i, 1);
                                yval=labelxy(i, 2);
                                roi=roixy{i, 1};
                                
                                text(xval, yval, label);
                                plot(roi(:,1), roi(:, 2), 'r');
                                hold off
                            end

                        else
                            if (labelxy(i, 1)>newXLim(1,1) && labelxy(i, 1)<newXLim(1,2) && labelxy(i, 2)>newYLim(1,1) && labelxy(i, 2)<newYLim(1,2))

                                hold on
                                label=int2str(cellnumber(1, i));
                                xval=labelxy(i, 1);
                                yval=labelxy(i, 2);
                                roi=roixy{i, 1};
                                                                
                                text(xval, yval, label);
                                plot(roi(:,1), roi(:, 2), 'r');
                                hold off
                            end

                        end
                    end
                end
            end
        end
    end

%------------------------------------------------------------------------%
% Export function to store the cell structure with the data and to store
% plotting metadata (plotinfo, roitoplot)
%------------------------------------------------------------------------%

    function ExportData(hObject, eventdata, extdata)
        
         [filname,pathfile]=uiputfile('*.mat', 'Save ROI Files');
        
        global extdata
        
        exppath=[pathfile, filname];
        save(exppath, '-struct', 'extdata', '-v7.3');
        
    end

%------------------------------------------------------------------------%
% Create Keyboard shrotcuts
%------------------------------------------------------------------------%

    function myShortKey(src, evnt)
        
        %initialize variables
        control = 0;
        alt = 0;
        shift = 0;

        %determine which modifiers have been pressed
        for x=1:length(evnt.Modifier)
            switch(evnt.Modifier{x})
                case 'control'
                    control = 1
                case 'alt'
                    alt = 1
                case 'shift'
                    shift = 1
            end
        end
        
        keytest=evnt.Key
        
        if (strcmp(evnt.Key, 'n'))        
            
            disp ('Create New Cell')
            NewCell()

        elseif (strcmp(evnt.Key, 'c'))            
            
            disp ('Remove Current Cell')            
            RemoveCell()
            
        elseif (strcmp(evnt.Key, 'r'))            
            
            disp ('Create New ROI')            
            CreateROI()
            
        elseif (strcmp(evnt.Key, 'd'))
            
            disp ('Remove Current ROI')
            RemoveROI()
            
        elseif (strcmp(evnt.Key, 's'))
            
            disp ('Save Cell')            
            SaveCell()
            
        elseif (strcmp(evnt.Key, 'e'))
        
            disp ('Export Data')            
            ExportData()
            
        elseif (strcmp(evnt.Key, 'z'))
            
            if (strcmp(get(zoom, 'Enable'), 'on'))
                
                a= strcmp(get(zoom, 'Enable'), 'on')
                zoom off
                
            else
                
                zoom on
                
            end
            
        elseif (strcmp(evnt.Key, 'leftarrow'))
            
            disp ('Left Arrow')
            imagenb=get(slh,'Value');
            imagenb=imagenb-1;
            set(slh, 'Value', imagenb);
            Move_stack()
            
        elseif (strcmp(evnt.Key, 'rightarrow'))
            
            disp ('Right Arrow')

            imagenb=get(slh,'Value');
            imagenb=imagenb+1;
            set(slh, 'Value', imagenb);
            Move_stack()
            
        end
    end

%------------------------------------------------------------------------%
% Visualize data
%------------------------------------------------------------------------%

    function VisuInterface(hObject, eventdata, extdata)
        
        global extdata
        RGBdata=[];
        
        RGBdata=ExtractMeanDataMod(extdata, RGBdata);
        PlotMultiGraphs(RGBdata);
        
    end

end