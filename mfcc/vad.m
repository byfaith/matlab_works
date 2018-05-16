clear all;
clc;
%%
Fs=8000;
[speech,fs,nbits]=wavread('Ch_f4.wav');
x=resample(speech,Fs,fs);
x=x./max(abs(x));
L=240;
R=80;
amp1=10;
amp2=2;
zcr1=10;
zcr2=5;
maxsilence=8;%80ms
minlen=15;
status=0;
count=0;
silence=0;
tmp1=enframe(x(1:end-1),L,R);
tmp2=enframe(x(2:end),L,R);
signs=(tmp1.*tmp2)<0;
diffs=(tmp1-tmp2)>0.02;
zcr=sum(signs.*diffs,2);%each,frame
amp=sum(abs(enframe(filter([1,-0.9375],1,x),L,R)),2);
amp1=min(amp1,max(amp)/4);%T.H
amp2=min(amp2,max(amp)/8);%T.L
vadf=zeros(length(x),1);
x1=0;
x2=0;
for n=1:1:length(zcr),
    switch(status),
        case{0,1},
            if(amp(n)>amp1),
                x1=max(n-count-1,1);%from,status==1
                status=2;
                silence=0;
                count=count+1;
            elseif(amp(n)>amp2|zcr(n)>zcr2),
                status=1;
                count=count+1;
            else
                status=0;
                count=0;
            end
        case{2},
            if(amp(n)>amp2|zcr(n)>zcr2),
                count=count+1;
                silence=0;
            else
                silence=silence+1;
                if(silence<maxsilence),
                    count=count+1;
                elseif count<minlen,
                    status=0;
                    silence=0;
                    count=0;
                else
                    status=3;
                end
            end
        case{3},
            break;
    end
end

count=count-silence/2;
x2=x1+count-1;
n1=floor((x1+2)/3)*240;
n2=floor((x2+2)/3)*240;
vadf(n1:n2)=1;