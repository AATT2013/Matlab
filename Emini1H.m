clear;
N=150000; %the smallest number of rows in all the historical data

frequency=60;
 
%%%input data of GSPC
ESVOLUM=csvread('C:\Program Files (x86)\YLoader\data\ES.csv',0,4);
[rows,columns]=size(ESVOLUM);
ES=0.01*csvread('C:\Program Files (x86)\YLoader\data\ES.csv',rows-N-1,0, [rows-N-1,0,rows-1,3]);
ESVOLUM=0.01*ESVOLUM((rows-N):rows,1:1);

ES=[ES,ESVOLUM];



a=1;
b=1;
c=floor((N+1)/frequency);
E60=zeros(c,5);
while a<=floor(c)
     
    E60(a,1)=ES(frequency*a-frequency+1,1);
    E60(a,5)=0;
    E60(a,2)=ES(frequency*a);
    E60(a,3)=ES(frequency*a);
    for i=0:(frequency-1)
    E60(a,2)=max(E60(a,2),ES(frequency*a-i));
    E60(a,3)=min(E60(a,3),ES(frequency*a-i));
    
    E60(a,5)=ES(frequency*a-i)+E60(a,5);
    end
    E60(a,4)=ES(frequency*a,4);
   a=a+1; 
end


E60VOLUM=E60(1:c,5:end);
E60=E60(1:c,2:4);
 
inputSeries = tonndata(E60VOLUM,false,false);
targetSeries = tonndata(E60,false,false);

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:16;
feedbackDelays = 1:16;
hiddenLayerSize = 32;
net1H = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs,inputStates,layerStates,targets] = preparets(net1H,inputSeries,{},targetSeries);

% Setup Division of Data for Training, Validation, Testing
net1H.divideParam.trainRatio = 70/100;
net1H.divideParam.valRatio = 15/100;
net1H.divideParam.testRatio = 15/100;

% Train the Network
[net1H,tr] = train(net1H,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net1H(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net1H,targets,outputs)

 
nets = removedelay(net1H);
nets.name = [net1H.name ' - Predict One Step Ahead'];
 
[xs,xis,ais,ts] = preparets(nets,inputSeries,{},targetSeries);
ys =nets(xs,xis,ais);
 
save Emini1Hnet net1H;










 