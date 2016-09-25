% Solve an Autoregression Time-Series Problem with a NAR Neural Network
% Script generated by NTSTOOL
% Created Mon Aug 01 09:39:01 EDT 2011
%
% This script assumes this variable is defined:
%
%   SPY - feedback time series.


N=5200; %the smallest number of rows in all the historical data

%%%input data of GSPC
GSPCVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^GSPC.csv',0,5);
[rows,columns]=size(GSPCVOLUM);
GSPC=csvread('C:\Program Files (x86)\YLoader\data\^GSPC.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
GSPCVOLUM=0.000001*GSPCVOLUM((rows-N):rows,1:1);
 


%%%input data of FCHI
FCHIVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^FCHI.csv',0,5);
[rows,columns]=size(FCHIVOLUM);
FCHI=csvread('C:\Program Files (x86)\YLoader\data\^FCHI.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
FCHIVOLUM=0.00001*FCHIVOLUM((rows-N):rows,1:1);


%%%input data of FTSE
FTSEVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^FTSE.csv',0,5);
[rows,columns]=size(FTSEVOLUM);
FTSE=csvread('C:\Program Files (x86)\YLoader\data\^FTSE.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
FTSEVOLUM=0.000001*FTSEVOLUM((rows-N):rows,1:1);


%%%input data of GDAXI
GDAXIVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^GDAXI.csv',0,5);
[rows,columns]=size(GDAXIVOLUM);
GDAXI=csvread('C:\Program Files (x86)\YLoader\data\^GDAXI.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
GDAXIVOLUM=0.0001*GDAXIVOLUM((rows-N):rows,1:1);


%%%input data of HSI
HSIVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^HSI.csv',0,5);
[rows,columns]=size(HSIVOLUM);
HSI=csvread('C:\Program Files (x86)\YLoader\data\^HSI.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
HSIVOLUM=0.0001*HSIVOLUM((rows-N):rows,1:1);

%%%input data of N225
N225VOLUM=csvread('C:\Program Files (x86)\YLoader\data\^N225.csv',0,5);
[rows,columns]=size(N225VOLUM);
N225=csvread('C:\Program Files (x86)\YLoader\data\^N225.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
N225VOLUM=0.1*N225VOLUM((rows-N):rows,1:1);


VIXVOLUM=csvread('C:\Program Files (x86)\YLoader\data\^VIX.csv',0,5);
[rows,columns]=size(VIXVOLUM);
VIX=csvread('C:\Program Files (x86)\YLoader\data\^VIX.csv',rows-N-1,1, [rows-N-1,1,rows-1,4]);
 


 

ALLOVER=[FCHI,FTSE,GDAXI,N225,VIX];
ALLOVERVOLUM=[ALLOVER,FCHIVOLUM,FTSEVOLUM,GDAXIVOLUM,GSPCVOLUM,N225VOLUM ];
inputSeries = tonndata(ALLOVERVOLUM,false,false);
targetSeries = tonndata(GSPC,false,false);

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:8;
feedbackDelays = 1:8;
hiddenLayerSize = 25;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);
 

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs,inputStates,layerStates,targets] = preparets(net,inputSeries,{},targetSeries);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;


 
% Train the Network
[net,tr] = train(net,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

 
% Early Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is given y(t+1).
% For some applications such as decision making, it would help to have predicted
% y(t+1) once y(t) is available, but before the actual y(t+1) occurs.
% The network can be made to return its output a timestep early by removing one delay
% so that its minimal tap delay is now 0 instead of 1.  The new network returns the
% same outputs as the original network, but outputs are shifted left one timestep.
nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
view(nets)
[xs,xis,ais,ts] = preparets(nets,inputSeries,{},targetSeries);
ys = nets(xs,xis,ais);
 A=ys{:,N-6}';
csvwrite('C:\Company\result.csv', A(1:4));
f = ftp('ftp.ipage.com','aatsyscom','DongFeng09$$');
delete(f,'result.csv');
mput(f,'C:\Company\result.csv');
 close(f);