function varargout = color_calib_UI(varargin)
% COLOR_CALIB_UI MATLAB code for color_calib_UI.fig
%      COLOR_CALIB_UI, by itself, creates a new COLOR_CALIB_UI or raises the existing
%      singleton*.
%
%      H = COLOR_CALIB_UI returns the handle to a new COLOR_CALIB_UI or the handle to
%      the existing singleton*.
%
%      COLOR_CALIB_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLOR_CALIB_UI.M with the given input arguments.
%
%      COLOR_CALIB_UI('Property','Value',...) creates a new COLOR_CALIB_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before color_calib_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to color_calib_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help color_calib_UI

% Last Modified by GUIDE v2.5 12-May-2021 11:05:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @color_calib_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @color_calib_UI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before color_calib_UI is made visible.
function color_calib_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to color_calib_UI (see VARARGIN)
global white_point chk_selec fit_mtd color_space ref_data patch_size All_patches
global gamma

addpath(genpath(pwd));
[white_point,color_space] = deal({''});
white_point{1} = 'D65'; % 'A' | 'C' | 'D50' | 'D55' | 'D65' |'D75' | 'F2' | 'F11'
white_point{2} = lower(white_point{1});

color_space{1} = 'xyz'; % 'xyz' | 'sRGB'
color_space{2} = upper(color_space{1});

chk_selec = 'XRite_Classic'; % 'XRite_Classic' | 'XRite_DSG' | 'XRite_DC' 
All_patches = [10,14;...
        12,20;...
        4,6];
patch_size = All_patches(3,:);
gamma = 1;

fit_mtd = 'root6x3'; % 'linear3x3'| 'root6x3' | 'root13x3' |'poly4x3' | 'poly6x3' | 'poly7x3' | 'poly9x3'
load('spectral_reflectance_data.mat'); % load reference color chart data
ref_data = spectral_reflectance_data;

% set default popup
handles.wp_choice.Value = 5;
handles.chk_type.Value = 3;
handles.fit_type.Value = 2;
handles.color_opt.Value = 1;
handles.gamma_val.String = num2str(gamma);
drawnow;
% Choose default command line output for color_calib_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes color_calib_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = color_calib_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in get_color_chart.
function get_color_chart_Callback(hObject, eventdata, handles)
% hObject    handle to get_color_chart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Im_ref

handles.rotate.Visible = 'On';

[my_file,my_dir] = uigetfile('*.*');
try
    image_dir = [my_dir,my_file];

    Im_ref = imread(image_dir);
    
    if ~isa(Im_ref,'uint8')
        Im_ref = im2uint8(Im_ref);
    end

    imshow(Im_ref,'Parent',handles.axes_orig);
catch
    warndlg('Try to select color chart image file again','No file selected...')
end


% --- Executes on button press in run_color_corr.
function run_color_corr_Callback(hObject, eventdata, handles)
% hObject    handle to run_color_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ccm Im_ref white_point chk_selec fit_mtd color_space ref_data patch_size All_patches 
global coords Csg_img gains gamma whitePoint

I_wait = imread('please_Wait.jpg');
imshow(I_wait, 'Parent', handles.axes_correct);

eval(['spectra = ref_data.',chk_selec,';']);

my_refData = spectra2colors(spectra, 400:5:700,...
                     'spd', white_point{1},...
                     'output', color_space{2});

% roi of color patches from refernce image
patch_size_choices = find([(contains(chk_selec,'XRite_DSG'));...
            (contains(chk_selec,'XRite_DC'));...
            (contains(chk_selec,'XRite_Classic'))]);
patch_size = All_patches(patch_size_choices,:); 

[my_RGB, coords] = checker2colors(Im_ref, patch_size,...
                         'allowadjust', true,... 
                         'roisize', 30,...
                         'show', true,...
                         'scale', 2); % scaling only for better visualization
                     
                     
% color correction with white point preserved                     
neutral_patches = {[61:65];...
    [0 0 0 0 0];... % not accurate, please try to search for this
    [19:24]};

neutral_patches_idx = neutral_patches{patch_size_choices}; 

gains = [my_RGB(neutral_patches_idx, 1) \ my_RGB(neutral_patches_idx, 2),...
         1,...
         my_RGB(neutral_patches_idx, 3) \ my_RGB(neutral_patches_idx, 2)];
     
RGB_wb = my_RGB .* gains;

whitePoint = whitepoint(white_point{2});


% training
[ccm, scale, XYZ_pred, errs_train] = ccmtrain(RGB_wb,...
                                                 my_refData,...
                                                 'model', fit_mtd,...
                                                 'targetcolorspace', color_space{1},...
                                                 'whitepoint', whitePoint);

% visualze

colors2checker(RGB_wb,...
               'layout', patch_size,...
               'squaresize', 100,...
               'parent', handles.axes_orig);


colors2checker(xyz2rgb(XYZ_pred),...
               'layout', patch_size,...
               'squaresize', 100,...
               'parent', handles.axes_correct);
try
    close Figure 1
end

pause(5)

sz = size(Im_ref);

% convert images to range btn 1 and 0
Im_2 = double(Im_ref)./((2^8)-1);

r_dsg_img = reshape(Im_2,sz(1)*sz(2),3).*gains;
% r_dsg_img = rescale(r_dsg_img,0,1);
r_dsg_img(r_dsg_img>1) = 1;

c_dsg_img = ccmapply(r_dsg_img,...
                     fit_mtd,...
                     ccm);

C_dsg_img = reshape(c_dsg_img,sz(1),sz(2),3);

if strcmp(color_space{1},'xyz')
    Csg_img = xyz2rgb(C_dsg_img,'WhitePoint',whitePoint,'OutputType','uint8');
elseif strcmp(color_space{1},'sRGB')
    Csg_img = C_dsg_img;
end

Csg_img = imadjust(Csg_img,[],[], gamma);
imshow(Im_ref, [], 'Parent', handles.axes_orig)
imshow(Csg_img, [], 'Parent', handles.axes_correct)

drawnow;


% --- Executes on button press in save_ccm.
function save_ccm_Callback(hObject, eventdata, handles)
% hObject    handle to save_ccm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ccm fit_mtd gains gamma color_space whitePoint

[file,path,indx] = uiputfile('CCM.mat');

cs = color_space{1};
if indx
    save([path,file], 'ccm', 'fit_mtd', 'gains','gamma', 'cs', 'whitePoint');
else
    save('CCM.mat', 'ccm', 'fit_mtd', 'gains', 'gamma', 'cs', 'whitePoint');
end
msgbox('Saving complete...',  'Done!!!')

% --- Executes on button press in exit_btn.
function exit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to exit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close color_calib_UI;

% --- Executes on selection change in chk_type.
function chk_type_Callback(hObject, eventdata, handles)
% hObject    handle to chk_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global chk_selec

contents = cellstr(get(hObject,'String'));
chk_selec = contents{get(hObject,'Value')};

% Hints: contents = cellstr(get(hObject,'String')) returns chk_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chk_type


% --- Executes during object creation, after setting all properties.
function chk_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chk_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fit_type.
function fit_type_Callback(hObject, eventdata, handles)
% hObject    handle to fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fit_mtd
contents = cellstr(get(hObject,'String'));
fit_mtd = contents{get(hObject,'Value')};


% --- Executes during object creation, after setting all properties.
function fit_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fit_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color_opt.
function color_opt_Callback(hObject, eventdata, handles)
% hObject    handle to color_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global color_space

contents = cellstr(get(hObject,'String'));
       
color_space{1} = contents{get(hObject,'Value')};
color_space{2} = upper(color_space{1});

% Hints: contents = cellstr(get(hObject,'String')) returns color_opt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_opt


% --- Executes during object creation, after setting all properties.
function color_opt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wp_choice.
function wp_choice_Callback(hObject, eventdata, handles)
% hObject    handle to wp_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global white_point

contents = cellstr(get(hObject,'String'));
white_point{1} = contents{get(hObject,'Value')};
white_point{2} = lower(white_point{1});

% Hints: contents = cellstr(get(hObject,'String')) returns wp_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wp_choice



function gamma_val_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gamma Csg_img
gamma = str2double(get(hObject,'String'));

Csg_img1 = imadjust(Csg_img,[],[], gamma);
imshow(Csg_img1, [], 'Parent', handles.axes_correct)
drawnow
% Hints: get(hObject,'String') returns contents of gamma_val as text
%        str2double(get(hObject,'String')) returns contents of gamma_val as a double


% --- Executes during object creation, after setting all properties.
function gamma_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotate.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Im_ref
Im_ref = rot90(Im_ref);
imshow(Im_ref, 'Parent', handles.axes_orig);
drawnow;
