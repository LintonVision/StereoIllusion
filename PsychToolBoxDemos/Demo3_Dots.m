%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%
%                           LINTON STEREO ILLUSION:
%
%                              DOTS AS STIMULUS
%
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

% Demo intended for a 27inch display viewed at 40cm

%-------------------------------------------------------------------------------
% CLEAR THE PREVIOUS WORKSPACE
%-------------------------------------------------------------------------------

%START FROM SCRATCH
sca;close all;clear all;
Screen('Preference','SkipSyncTests', 1); 

%-------------------------------------------------------------------------------
% PARAMETERS
%-------------------------------------------------------------------------------

%IPD
IPD = 6.4;

%VIEWING DISTANCE
viewingDist = 40;

%STIMULUS SPEED
time = 0.4; %Time per cycle

%SET STEREO MODE
stereoMode = 8; %Set to anagylph

%-------------------------------------------------------------------------------
% WORK OUT INITIAL DISTANCES AND ANGLES
%-------------------------------------------------------------------------------

%DISTANCE OF BACK CIRCLE AT START
Dist1 = 50; Theta1 = atand((Dist1) / (0.5*IPD));

%DISTANCE OF FRONT CIRCLE AT START + BACK CIRCLE AT END
Dist2 = 40; Theta2 = atand((Dist2) / (0.5*IPD)); 

%DISTANCE OF FRONT CIRCLE AT END <- MINIMAL MODEL
Dist3A = tand(2*Theta2 - Theta1) * (0.5*IPD); Theta3A = (2*Theta2 - Theta1);

%DISTANCE OF FRONT CIRCLE AT END <- TRIANGULATION MODEL
Dist3B = 40-10; Theta3B = atand((Dist3B) / (0.5*IPD));

%-------------------------------------------------------------------------------
% GET STIMULI
%-------------------------------------------------------------------------------

GetCircles; % Seperate script

%-------------------------------------------------------------------------------
% GET SCREEN WIDTH AND HEIGHT
%-------------------------------------------------------------------------------

% GET SCREEN SIZE IN MM
[screenWidth, screenHeight] = Screen('DisplaySize',0);

% DIVIDE BY 10 TO GET CM
screenWidth = screenWidth/10;
screenHeight = screenHeight/10;

%-------------------------------------------------------------------------------
% DEFINE OPENGL CAMERA IN PHYSICAL COORDINATES
%-------------------------------------------------------------------------------

%NEAR AND FAR CLIPPING DISTANCE
clipNear = 20; clipFar = 60;

%VERTICAL OFFSET
top = 0.5*screenHeight * clipNear / viewingDist; %Y-axis coordinates for top of the near clipping plane
bottom = -0.5*screenHeight * clipNear / viewingDist; %Y-axis coordinates for bottom of the near clipping plane

%RIGHT EYE ASYMMETRIC FRUSTRUM
rightEyeRightFrustrum = (0.5*screenWidth - 0.5*IPD +4) * clipNear / viewingDist;
rightEyeLeftFrustrum = (-0.5*screenWidth - 0.5*IPD +4) * clipNear / viewingDist;

rightEyeRightFrustrum2 = (0.5*screenWidth - 0.5*IPD -4) * clipNear / viewingDist;
rightEyeLeftFrustrum2 = (-0.5*screenWidth - 0.5*IPD -4) * clipNear / viewingDist;

%LEFT EYE ASYMMETRIC FRUSTRUM
leftEyeRightFrustrum = (0.5*screenWidth + 0.5*IPD +4) * clipNear / viewingDist;
leftEyeLeftFrustrum = (-0.5*screenWidth + 0.5*IPD +4) * clipNear / viewingDist;

leftEyeRightFrustrum2 = (0.5*screenWidth + 0.5*IPD -4) * clipNear / viewingDist;
leftEyeLeftFrustrum2 = (-0.5*screenWidth + 0.5*IPD -4) * clipNear / viewingDist;

% CAMERA POSITION 
cameraPosition = [0, 0, viewingDist]; %Place camera virtualDist away from origin
cameraFixation = [0, 0, 0]; %Orient camera to look at origin
cameraOrientation = [0, 1, 0]; %Define camera "up" relative to the origin

%-------------------------------------------------------------------------------
% INITIALISE SCREEN + INPUT + OPENGL
%-------------------------------------------------------------------------------

% INITIALISE SCREEN
[win, winRect] = Screen('OpenWindow', 0, [0 0 0], [], [], [], stereoMode);
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% INITIALISE KEYBOARD + MOUSE
KbName('UnifyKeyNames'); 
HideCursor();

% INITIALISE OPENGL
InitializeMatlabOpenGL; 

%-------------------------------------------------------------------------------
% START CLOCK
%-------------------------------------------------------------------------------

tic;

%-------------------------------------------------------------------------------
% WHILE TRUE
%-------------------------------------------------------------------------------

while true

%-------------------------------------------------------------------------------
% 
%-------------------------------------------------------------------------------

Dist2 = tand(Theta2 + (Theta1-Theta2)*0.5*(cos(pi*(1 + toc/time))+1)) * (0.5*IPD);

Dist3A = tand(Theta3A + (Theta2-Theta3A)*0.5*(cos(pi*(1 + toc/time))+1)) * (0.5*IPD);

Dist3B = tand(Theta3B + (Theta2-Theta3B)*0.5*(cos(pi*(1 + toc/time))+1)) * (0.5*IPD);

%-------------------------------------------------------------------------------
% 
%-------------------------------------------------------------------------------

Dist2Scaling = Dist2/viewingDist; 

Dist3AScaling = Dist3A/viewingDist; 

Dist3BScaling = Dist3B/viewingDist; 

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%                   DO RENDERING FOR TRIANGULATION MODEL
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(leftEyeLeftFrustrum, leftEyeRightFrustrum, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for left eye 

%-------------------------------------------------------------------------------
% DEFINE CAMERA POSITION IN SCENE FOR LEFT EYE CAMERA
%-------------------------------------------------------------------------------

glMatrixMode(GL.MODELVIEW); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

gluLookAt(cameraPosition(1), cameraPosition(2), cameraPosition(3), ... %Specify camera Position 
        cameraFixation(1), cameraFixation(2), cameraFixation(3), ... %Direction
        cameraOrientation(1), cameraOrientation(2), cameraOrientation(3)); %And Orientation 

%-------------------------------------------------------------------------------
% DRAW STIMULI ON LEFT EYE BUFFER
%-------------------------------------------------------------------------------

Screen('SelectStereoDrawBuffer', win, 0); % <- Buffer 0 shows stimuli to left eye

glTranslatef(0.5*IPD, 0,0);
Screen('FillPoly', win, [255 255 255], 0.5*1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 0.5*1.5*0.9*backCircle');
%Screen('FillPoly', win, [0 0 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*-2.5, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*5, 0, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');


glTranslatef(0.7*-2.5, 0.7*2, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glTranslatef(0, 0.7*-4, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glPopMatrix; % Finished with the Left eye

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR RIGHT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(rightEyeLeftFrustrum, rightEyeRightFrustrum, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for right eye 

%---------------------------------------------------------------------------------------------------------------
% DEFINE CAMERA POSITION IN SCENE FOR RIGHT EYE CAMERA
%---------------------------------------------------------------------------------------------------------------

glMatrixMode(GL.MODELVIEW); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

gluLookAt(cameraPosition(1), cameraPosition(2), cameraPosition(3), ... %Specify camera Position 
        cameraFixation(1), cameraFixation(2), cameraFixation(3), ... %Direction
        cameraOrientation(1), cameraOrientation(2), cameraOrientation(3)); %And Orientation 

%-------------------------------------------------------------------------------
% DRAW STIMULI ON RIGHT EYE BUFFER
%-------------------------------------------------------------------------------

Screen('SelectStereoDrawBuffer', win, 1); % <- Buffer 1 shows stimuli to right eye

glTranslatef(-0.5*IPD, 0,0);
Screen('FillPoly', win, [255 255 255], 0.5*1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 0.5*1.5*0.9*backCircle');
%Screen('FillPoly', win, [0 0 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*-2.5, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*5, 0, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');


glTranslatef(0.7*-2.5, 0.7*2, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glTranslatef(0, 0.7*-4, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glPopMatrix; % Finished with the Right eye

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%                   DO RENDERING FOR MINIMAL MODEL
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR LEFT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(leftEyeLeftFrustrum2, leftEyeRightFrustrum2, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for left eye 

%---------------------------------------------------------------------------------------------------------------
% DEFINE CAMERA POSITION IN SCENE FOR LEFT EYE CAMERA
%---------------------------------------------------------------------------------------------------------------

glMatrixMode(GL.MODELVIEW); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

gluLookAt(cameraPosition(1), cameraPosition(2), cameraPosition(3), ... %Specify camera Position 
        cameraFixation(1), cameraFixation(2), cameraFixation(3), ... %Direction
        cameraOrientation(1), cameraOrientation(2), cameraOrientation(3)); %And Orientation 

%-------------------------------------------------------------------------------
% DRAW STIMULI ON LEFT EYE BUFFER
%-------------------------------------------------------------------------------

Screen('SelectStereoDrawBuffer', win, 0); % <- Buffer 0 shows stimuli to left eye

%DRAW FRAME
glTranslatef(0.5*IPD, 0,0);
Screen('FillPoly', win, [255 255 255], 0.5*1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 0.5*1.5*0.9*backCircle');
%Screen('FillPoly', win, [0 0 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*-2.5, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*5, 0, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');


glTranslatef(0.7*-2.5, 0.7*2, Dist2-Dist3A);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glTranslatef(0, 0.7*-4, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glPopMatrix; % Finished with the Left eye

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR RIGHT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(rightEyeLeftFrustrum2, rightEyeRightFrustrum2, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for right eye 

%---------------------------------------------------------------------------------------------------------------
% DEFINE CAMERA POSITION IN SCENE FOR RIGHT EYE CAMERA
%---------------------------------------------------------------------------------------------------------------

glMatrixMode(GL.MODELVIEW); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

gluLookAt(cameraPosition(1), cameraPosition(2), cameraPosition(3), ... %Specify camera Position 
        cameraFixation(1), cameraFixation(2), cameraFixation(3), ... %Direction
        cameraOrientation(1), cameraOrientation(2), cameraOrientation(3)); %And Orientation 

%-------------------------------------------------------------------------------
% DRAW STIMULI ON RIGHT EYE BUFFER
%-------------------------------------------------------------------------------

Screen('SelectStereoDrawBuffer', win, 1); % <- Buffer 1 shows stimuli to left eye

%DRAW FRAME
glTranslatef(-0.5*IPD, 0,0);
Screen('FillPoly', win, [255 255 255], 0.5*1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 0.5*1.5*0.9*backCircle');
%Screen('FillPoly', win, [0 0 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*-2.5, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

%DRAW FRAME
glTranslatef(0.7*5, 0, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');


glTranslatef(0.7*-2.5, 0.7*2, Dist2-Dist3A);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glTranslatef(0, 0.7*-4, 0);
Screen('FillPoly', win, [255 255 255], 0.05*backCircle');

glPopMatrix; % Finished with the Right eye

%-------------------------------------------------------------------------------
% FLIP BUFFERS TO PRESENT ON SCREEN
%-------------------------------------------------------------------------------

Screen('Flip', win);

%-------------------------------------------------------------------------------
% CHANGE DISPARITY OF NEAR STIMULUS
%-------------------------------------------------------------------------------

[keyIsDown, ~, keyCode] = KbCheck(-1); %Record various components of KbCheck

if keyIsDown == 1
  
      break 
 
end
%
end
%
sca;
