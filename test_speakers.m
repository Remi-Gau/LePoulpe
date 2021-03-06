function test_speakers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% TEST TEST TEST TEST
% cd edited 26.11.2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START the AO
% Slot2 ao0-14 is left arm
% Slot2 ao15-30 is right arm (center speaker included here), ao30 is center
% Slot3 ao0-14 upper arm
% Slot3 ao15-29 below arm
% all 4 arms, the direction is approaching to the center

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
%% CHOOSE/CHANGE HERE ONLY 
% Insert Slot2 && data =0; OR Slot3 && data = 1,
AOLR=analogoutput('nidaq','PXI1Slot2'); 
data = 0; % this is used for digital swicth turn on/off

%% Default parameters, initiations
out_AO=daqhwinfo(AOLR);
set(AOLR, 'SampleRate', 44100);
addchannel(AOLR,0:30);
condition = 99;
%% Digital switch
% To turn it on/off
 dio = digitalio('nidaq', 'PXI1Slot3');
 addline (dio, 0:7, 'out');
 putvalue(dio.Line(1),data);
 value = getvalue(dio);
%% Analog channels initiation
% Define range
out_ranges = get(AOLR.Channel,'OutputRange');
setverify(AOLR.Channel,'OutputRange', [-5 5]);
setverify(AOLR.Channel,'UnitsRange', [-5 5]);
set(AOLR,'TriggerType', 'Manual');

%% SOUND FILES
addpath(genpath(pwd));
pathname = '/input_sounds';
sound_filename = fullfile(pathname,'pn_1250ms_50msfadeinout.wav');
%load .wav file
[sound_array, ~] = audioread(sound_filename);

totspeaker = 31;
amp = 1; %the intensity of sound, max 1
AOLR.SampleRate = 44100; %should not be necessary !


% speaker orders from most left to most right
% 1:15 31:-1:16
speaker_array = [1:15 31:-1:16];
chosen_sound = ones(1,31);
gap = 0.0;

%first raw for the speaker, second raw for the sounds/audio
%this is only for experimenter to see how the sound/speaker combination
%will work
%sequence_channel = [speaker_array; chosen_sound]; 

%preallocation
wav_length = length(sound_array);
data = zeros(wav_length,totspeaker); %zeros(righe,4) %out_AO.TotalChannels



%% Load the .wav file for each channel/speaker
fin = 0;
for j = 1:length(speaker_array)
    
    iniz= fin+1;
    fin=iniz+length(sound_array)-1+ gap;
    data(iniz:(fin-gap),speaker_array(j))=amp*sound_array;   %*2 looks like amplifier here
    
end

%below is for experimenter to visualise the sequence
figure;imagesc(data);

% waiting time - matlab should do nothing during waiting time
dur = size(data,1)/44100; %in sec

%% START
putdata(AOLR,data) % to queue the obj
% Start AO, issue a manual trigger, and wait for
% the device object to stop running.
start(AOLR)
%pause(1) %when to start exp
trigger(AOLR)
%stop(AO) terminates the execution

wait(AOLR, dur+1) %wait before doing anything else

toc
delete(dio)
clear dio

delete(AOLR)
clear AO

end
