clear;
zongshu=2975;
path='C:\Users\eddy\Documents\GitHub\Matlab\russell_3000_2011-06-27.csv';
file=fopen(path);
symbols=textscan(file,'%s','delimiter', ',');
 
symbols=[symbols{:}]; 
fclose('all'); 

result ='';
 
for i=0:1
AllSymbols=char(symbols(1+1000*i));

for s=(2+1000*i):(i+1)*1000

AllSymbols= [AllSymbols '+' char(symbols(s))];

end
url=['http://finance.yahoo.com/d/quotes.csv?s=' AllSymbols '&f=sp6p5r5j1s7pm4']; %%'&f=snd1l1yr']; p6 Price/Book p5 Price/Sales   
 % r5 PEG Ratio  j1 Market Cap  s7 Short Ratio  w 52 week change 
 %m4 200-day Moving Average         p previous close                                         
result =[result,urlread(url)];
 

end

 
 


 fileID= fopen('data.csv', 'w') ;
 
% fprintf(fileID, '%s%s\n', result) ;
fprintf(fileID,  result) ;
 fclose(fileID);
 
 data = csvread('data.csv',1,1);
 
 