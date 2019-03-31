clear
% 因文字格式不同，最早能從2010年08月開始分析
StartYear=2010; 
StartMon=8;
EndYear=2019;
EndMon=3;
%% 分出年分
YearURL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/index.html';
YearStr = urlread(YearURL);
YearExp = '<a[^>]*>(.*?)</a>';  %Year Expression 
YearMatches = regexp(YearStr,YearExp,'match'); 
YearUrlArray = strings;
for Mon=1:length(YearMatches)
    TorF=textscan(cell2mat(YearMatches(1,Mon)),'<a href="%s">');
    if(~cellfun(@isempty,TorF))
        YearUrl=cell2mat(YearMatches(1,Mon));
        if(YearUrlArray(1)=="")
            YearUrlArray=string(YearUrl);
        else
            YearUrlArray(end+1)=string(YearUrl);
        end
    end
end
%% 取得年分URL
for Year=1:length(YearUrlArray)
    Cref=textscan(YearUrlArray(Year),'<a href="%[^">]');
    Tref=cell2mat(Cref{1,1});
    YearUrlArray(Year)=['https://www.ptt.cc',Tref];
end
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D53F/index.html'; %2018
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D822/index.html';%2017
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D471/index.html';%2016
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D38B/index.html';%2015
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/DF34/index.html';%2014
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D949/index.html';%2013
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D686/index.html';%2012
%URL='https://www.ptt.cc/man/PttEarnMoney/DEB7/D24C/D6C2/index.html';%2011

%%
LotteryArray=[];
for Year=StartYear-2006:EndYear-2006
    MonStr=urlread(char(YearUrlArray(Year)));
    MonExp = '<a[^>]*>(.*?)</a>';
    MonMatchess=regexp(MonStr,MonExp,'match');
    
    MonUrlArray=strings;
    for Mon=1:length(MonMatchess)
        TorF=textscan(cell2mat(MonMatchess(1,Mon)),'<a href="%s">');
        if(~cellfun(@isempty,TorF))
            MonthUrl=cell2mat(MonMatchess(1,Mon));
            if(MonUrlArray(1)=="")
                MonUrlArray=string(MonthUrl);
            else
                MonUrlArray(end+1)=string(MonthUrl);
            end
        end
    end
    %% 分析每局
    if ((Year+2006)==StartYear)TempStartMon=StartMon;
    else TempStartMon=1;end
    if ((Year+2006)==EndYear)TempEndMon=EndMon;
    else TempEndMon=12;end
    %%
    for Month=TempStartMon:TempEndMon
        Cref=textscan(MonUrlArray(Month),'<a href="%[^">]');
        Tref=cell2mat(Cref{1,1});
        LotteryURL=['https://www.ptt.cc',Tref];

        LotteryStr=urlread(LotteryURL);
        MonExp = '<body[^>]*>(.*?)</body>';
        LotteryBodyStr=regexp(LotteryStr,MonExp,'match');
        LotteryCell=textscan(cell2mat(LotteryBodyStr),'%{MM/dd/yyyy}D %{HH:mm:ss}D %s');
        for Lottery=1:length(LotteryCell{1,1})
            if(~isnat(LotteryCell{1,1}(Lottery)) && ~isnat(LotteryCell{1,2}(Lottery)))
                LotteraCNum=textscan(cell2mat(LotteryCell{1,3}(Lottery)),'[%c]');
                if(isempty(cell2mat(LotteraCNum)))    
                    continue
                end
                if(FHNumConv(cell2mat(LotteraCNum))==9) %口卡
                    continue
                end
                LotteryArray(end+1,:)=[Year+2006 Month FHNumConv(cell2mat(LotteraCNum))];
            end
        end
    end
end
save('LotteryArray.mat')

%%
SearchStartYear=2018; 
SearchStartMon=11;
SearchEndYear=2019;
SearchEndMon=3;
Index=[find(LotteryArray(:,1)==SearchStartYear & LotteryArray(:,2)==SearchStartMon,1):...
    find(LotteryArray(:,1)==SearchEndYear & LotteryArray(:,2)==SearchEndMon,1,'last')];
y=histogram(LotteryArray(Index,3));