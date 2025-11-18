%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%
%                           LINTON STEREO ILLUSION:
%
%                       CHANGING VS FIXED ANGULAR SIZE
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
time = 0.75; %Time per cycle

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
rightEyeRightFrustrum = (0.5*screenWidth - 0.5*IPD +13) * clipNear / viewingDist;
rightEyeLeftFrustrum = (-0.5*screenWidth - 0.5*IPD +13) * clipNear / viewingDist;

rightEyeRightFrustrum2 = (0.5*screenWidth - 0.5*IPD) * clipNear / viewingDist;
rightEyeLeftFrustrum2 = (-0.5*screenWidth - 0.5*IPD) * clipNear / viewingDist;

rightEyeRightFrustrum3 = (0.5*screenWidth - 0.5*IPD -13) * clipNear / viewingDist;
rightEyeLeftFrustrum3 = (-0.5*screenWidth - 0.5*IPD -13) * clipNear / viewingDist;

%LEFT EYE ASYMMETRIC FRUSTRUM
leftEyeRightFrustrum = (0.5*screenWidth + 0.5*IPD +13) * clipNear / viewingDist;
leftEyeLeftFrustrum = (-0.5*screenWidth + 0.5*IPD +13) * clipNear / viewingDist;

leftEyeRightFrustrum2 = (0.5*screenWidth + 0.5*IPD) * clipNear / viewingDist;
leftEyeLeftFrustrum2 = (-0.5*screenWidth + 0.5*IPD) * clipNear / viewingDist;

leftEyeRightFrustrum3 = (0.5*screenWidth + 0.5*IPD -13) * clipNear / viewingDist;
leftEyeLeftFrustrum3 = (-0.5*screenWidth + 0.5*IPD -13) * clipNear / viewingDist;

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
%                   DO RENDERING FOR FIXED ANGULAR SIZE
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR LEFT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(leftEyeLeftFrustrum, leftEyeRightFrustrum, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for left eye 

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
glTranslatef(0.5*IPD, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 1.5*backCircle'*Dist2Scaling);
Screen('FillPoly', win, [0 0 0], 1.5*0.9*backCircle'*Dist2Scaling);
Screen('DrawDots', win, 1.5*0.95*backDots'*Dist2Scaling, 3, [255 255 255]);

%DRAW FRAME
glTranslatef(0, 0, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 1.5*frontCircle'*Dist3BScaling);
Screen('FillPoly', win, [0 0 0], 1.5*0.8*frontCircle'*Dist3BScaling);
Screen('DrawDots', win, 1.5*0.95*frontDots'*Dist3BScaling, 3, [255 255 255]);

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

%DRAW FRAME
glTranslatef(-0.5*IPD, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 1.5*backCircle'*Dist2Scaling);
Screen('FillPoly', win, [0 0 0], 1.5*0.9*backCircle'*Dist2Scaling);
Screen('DrawDots', win, 1.5*0.95*backDots'*Dist2Scaling, 3, [255 255 255]);

%DRAW FRAME
glTranslatef(0, 0, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 1.5*frontCircle'*Dist3BScaling);
Screen('FillPoly', win, [0 0 0], 1.5*0.8*frontCircle'*Dist3BScaling);
Screen('DrawDots', win, 1.5*0.95*frontDots'*Dist3BScaling, 3, [255 255 255]);

glPopMatrix; % Finished with the Right eye

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%                      DO RENDERING FOR FIXED TARGETS
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
glTranslatef(0.5*IPD, 50/40*2*5, -10);
Screen('FillPoly', win, [255 255 255], 0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 0.1*backCircle');

glTranslatef(0, 5-50/40*2*5, 10);
Screen('FillPoly', win, [255 255 255], 40/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 40/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 40/50*0.1*backCircle');

glTranslatef(0, -5, 10);
Screen('FillPoly', win, [255 255 255], 30/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 30/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 30/50*0.1*backCircle');

glTranslatef(0, -5, -10);
Screen('FillPoly', win, [255 255 255], 40/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 40/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 40/50*0.1*backCircle');

glTranslatef(0, 5-50/40*2*5, -10);
Screen('FillPoly', win, [255 255 255], 0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 0.1*backCircle');

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

Screen('SelectStereoDrawBuffer', win, 1); % <- Buffer 1 shows stimuli to right eye

%DRAW FRAME
glTranslatef(-0.5*IPD, 50/40*2*5, -10);
Screen('FillPoly', win, [255 255 255], 0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 0.1*backCircle');

glTranslatef(0, 5-50/40*2*5, 10);
Screen('FillPoly', win, [255 255 255], 40/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 40/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 40/50*0.1*backCircle');

glTranslatef(0, -5, 10);
Screen('FillPoly', win, [255 255 255], 30/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 30/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 30/50*0.1*backCircle');

glTranslatef(0, -5, -10);
Screen('FillPoly', win, [255 255 255], 40/50*0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 40/50*0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 40/50*0.1*backCircle');

glTranslatef(0, 5-50/40*2*5, -10);
Screen('FillPoly', win, [255 255 255], 0.4*backCircle');
Screen('FillPoly', win, [0 0 0], 0.4*0.6*backCircle');
Screen('FillPoly', win, [255 255 255], 0.1*backCircle');

glPopMatrix; % Finished with the Right eye

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%                   DO RENDERING FOR CHANGING ANGULAR SIZE
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR LEFT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(leftEyeLeftFrustrum3, leftEyeRightFrustrum3, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for left eye 

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
glTranslatef(0.5*IPD, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 1.5*0.9*backCircle');
Screen('DrawDots', win, 1.5*0.95*backDots', 3, [255 255 255]);

%DRAW FRAME
glTranslatef(0, 0, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 1.5*frontCircle'*30/40);
Screen('FillPoly', win, [0 0 0], 1.5*0.8*frontCircle'*30/40);
Screen('DrawDots', win, 1.5*0.95*frontDots'*30/40, 3, [255 255 255]);

glPopMatrix; % Finished with the Left eye

%-------------------------------------------------------------------------------
% DEFINE CAMERA IN PHYS FOR RIGHT EYE CAMERA
%-------------------------------------------------------------------------------

glPushMatrix; %Duplicate the existing matrix, because we're going to amend it

glMatrixMode(GL.PROJECTION); glLoadIdentity; %Tell OpenGL we're going to define Projection Matrix 

glFrustum(rightEyeLeftFrustrum3, rightEyeRightFrustrum3, bottom, top, clipNear, clipFar); %Specify asymmetric viewing frustum for right eye 

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

%DRAW FRAME
glTranslatef(-0.5*IPD, 0, viewingDist-Dist2);
Screen('FillPoly', win, [255 255 255], 1.5*backCircle');
Screen('FillPoly', win, [0 0 0], 1.5*0.9*backCircle');
Screen('DrawDots', win, 1.5*0.95*backDots', 3, [255 255 255]);

%DRAW FRAME
glTranslatef(0, 0, Dist2-Dist3B);
Screen('FillPoly', win, [255 255 255], 1.5*frontCircle'*30/40);
Screen('FillPoly', win, [0 0 0], 1.5*0.8*frontCircle'*30/40);
Screen('DrawDots', win, 1.5*0.95*frontDots'*30/40, 3, [255 255 255]);

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
