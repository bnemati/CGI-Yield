function histogram=superhist(varargin)
% superhist(-1, 1, .02, x, x-1, 'fred', 'george')

start_val=varargin{1};
end_val=varargin{2};
bin_size=varargin{3};
underflow=[];
overflow=[];
entries=[];
legend_temp=[];
means=[];
stddevs=[];
max_yet=0;



flag=0;
i=4;
while (flag==0);
    y=varargin{i};
    x = start_val:bin_size:end_val;
    under_ind=find(y<start_val);
    over_ind=find(y>end_val);
    underflow=[underflow length(under_ind)];
    overflow=[overflow length(over_ind)];
    entries=[entries length(y)];
    means=[means (mean(y))];
    stddevs=[stddevs (std(y))];
    y(cat(2,over_ind,under_ind))=[];
    [n,xout]=hist(y,x);
    if max(n)>max_yet
        max_yet=max(n);
    end

    switch i
        case (4)
            color=[1 0 0];
        case (5)
            color=[0 0 1];
        case (6)
            color=[0 1 0];
        case (7)
            color=[.7,.7,.4];
        case (8)
            color=[.5,.5,0];
        case (9)
            color=[.5,0,.5];
        case (10)
            color=[.75,.25,0];
        case (11)
            color=[.75,0,.25];
        case (12)
            color=[0,.75,.25];
    end
    stairs(xout,n,'Color',color)

    legend_temp=[legend_temp; strcat('data-',int2str(i-3))];
    %     h=area(xb,yb);
    %     set(h(1),'FaceColor',color)
    %     %area(xb,yb,'Color',color)
    hold on

    i=i+1;
    if (i>length(varargin))
        flag=2;
    end
    if (flag~=2) & (isstr(varargin{i}))
        flag=1;
    end
end
num_sets=i-4;
if (flag==1)
    flag=0;
    while (flag==0)
        this_legd=varargin{i};
        legend_temp(i-num_sets-3,1:length(this_legd))=[this_legd];
        legend_temp(i-num_sets-3,length(this_legd)+1:end)=[' '];
        i=i+1;
        if (i>length(varargin))
          flag=2;
        end
    end
end
        

legend(legend_temp)
plot([means(1)],[max_yet*1.3])
ax1 = axis;
t1x = ax1(1)+.02*(ax1(2)-ax1(1));
t1y = ax1(3)+(.97)*(ax1(4)-ax1(3));
t2x = ax1(1)+.15*(ax1(2)-ax1(1));
t3x = ax1(1)+.25*(ax1(2)-ax1(1));
t4x = ax1(1)+.39*(ax1(2)-ax1(1));
t5x = ax1(1)+.52*(ax1(2)-ax1(1));
t6x = ax1(1)+.61*(ax1(2)-ax1(1));
t7x = ax1(1)+.7*(ax1(2)-ax1(1));
text(t2x,t1y,['Entries'])
text(t3x,t1y,['Mean'])
text(t4x,t1y,['Sdev'])
text(t5x,t1y,['Under'])
text(t6x,t1y,['Over'])
for i=1:num_sets
    entries_pr=num2str(entries(i));
    und = num2str(underflow(i));
    over=num2str(overflow(i));
    stdev = num2str(stddevs(i), '%11.3g');
    mean_pr = num2str(means(i), '%11.3g');
    t1y = ax1(3)+(.96-(.04*i))*(ax1(4)-ax1(3));
    text(t1x,t1y,[legend_temp(i,:)]);
    text(t2x,t1y,[entries_pr]);
    text(t3x,t1y,[mean_pr]);
    text(t4x,t1y,[stdev]);
    text(t5x,t1y,[und]);
    text(t6x,t1y,[over]);
    t1y = ax1(3)+(.98-(.04*i))*(ax1(4)-ax1(3));
    plot(t1x:.1:(t7x),(t1y)*ones(1,length([t1x:.1:(t7x)])),'-k')


    %'  ' und ...
    %    '  ' over '  ' mean_pr '  ' ...
    %    stdev],'HorizontalAlignment','Left')
end
t1y = ax1(3)+(.94-(.04*i))*(ax1(4)-ax1(3));
plot(t1x:.1:(t7x),(t1y)*ones(1,length([t1x:.1:(t7x)])),'-k')
x_label_temp=legend_temp(1,:);
for i=2:num_sets
    x_label_temp=strcat(x_label_temp, ', ', legend_temp(i,:));
end
xlabel(x_label_temp);
ylabel(strcat('Entries / ',num2str(bin_size), ' bin'));
hold off
histogram=0;


