clear all
close all


load Controlled_Results.mat;
High_Con = All_Simu_Health;
Low_Con = All_Simu_UnHealth;

clear All_Simu_UnHealth All_Simu_UnHealth


load Merged_local_sensitivity_results.mat;

High_Simu = Fail_Simu;
Low_Simu = Success_Simu;


High_UnCon = cell(1,7);
Low_UnCon = cell(1,7);
High_Con_Stat = cell(1,7);
Low_Con_Stat = cell(1,7);


for j = 1:length(High_Simu)
   
        for i = 1:7
            if i == 5
                High_UnCon{1,i}(:,j) = log(High_Simu{1,j}(:,i));
                High_Con_Stat{1,i}(:,j) = log(High_Con{1,j}(:,i));
               
            else
                High_UnCon{1,i}(:,j) = High_Simu{1,j}(:,i);
                High_Con_Stat{1,i}(:,j) = High_Con{1,j}(:,i);
                
            end

        end
    
end


for j = 1:length(Low_Simu)
        for i = 1:7
            if i == 5
               
                Low_UnCon{1,i}(:,j) = log(Low_Simu{1,j}(:,i));
                Low_Con_Stat{1,i}(:,j) = log(Low_Con{1,j}(:,i));
            else
                
                Low_UnCon{1,i}(:,j) = Low_Simu{1,j}(:,i);
                Low_Con_Stat{1,i}(:,j) = Low_Con{1,j}(:,i);
            end

        end
    
end

tspan = 0:0.01:8;
L = length(tspan);

figure(1)
for ij = 1:4
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(High_UnCon{1,ij}(i,:));
        UnMatrix(2,i) = mean(High_UnCon{1,ij}(i,:));
        UnMatrix(3,i) = max(High_UnCon{1,ij}(i,:));
    
        ConMatrix(1,i) = min(High_Con_Stat{1,ij}(i,:));
        ConMatrix(2,i) = mean(High_Con_Stat{1,ij}(i,:));
        ConMatrix(3,i) = max(High_Con_Stat{1,ij}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    plot(tspan,ConMatrix(2,:),'Color',"#77AC30",'LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'g','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    if ij == 1
        ylabel('Neutrophil')
    elseif ij == 2
        ylabel('Monocyte')
    elseif ij == 3
        ylabel('M1')
    else
        ylabel('M2')
    end

end


for ij = 5
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(High_UnCon{1,ij}(i,:));
        UnMatrix(2,i) = mean(High_UnCon{1,ij}(i,:));
        UnMatrix(3,i) = max(High_UnCon{1,ij}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on
    xlabel('Time (day)') 
    ylabel('log(Pathogen)')
    xlim([0 8]) 
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
end

for ij = 6
    for i = 1:length(tspan)
        ConMatrix(1,i) = min(High_Con_Stat{1,ij-1}(i,:));
        ConMatrix(2,i) = mean(High_Con_Stat{1,ij-1}(i,:));
        ConMatrix(3,i) = max(High_Con_Stat{1,ij-1}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,ConMatrix(2,:),'Color',"#77AC30",'LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'g','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (day)') 
    ylabel('log(Pathogen)')
    xlim([0 8]) 
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)

end


for ij = 7:8
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(High_UnCon{1,ij-1}(i,:));
        UnMatrix(2,i) = mean(High_UnCon{1,ij-1}(i,:));
        UnMatrix(3,i) = max(High_UnCon{1,ij-1}(i,:));
    
        ConMatrix(1,i) = min(High_Con_Stat{1,ij-1}(i,:));
        ConMatrix(2,i) = mean(High_Con_Stat{1,ij-1}(i,:));
        ConMatrix(3,i) = max(High_Con_Stat{1,ij-1}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    plot(tspan,ConMatrix(2,:),'Color',"#77AC30",'LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'g','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (day)')   
    xlim([0 8]) 
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    if ij == 7
        ylabel('IL-6')
    else
        ylabel('TNF-\beta')
    end

end


figure(2)
for ij = 1:7
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(Low_UnCon{1,ij}(i,:));
        UnMatrix(2,i) = mean(Low_UnCon{1,ij}(i,:));
        UnMatrix(3,i) = max(Low_UnCon{1,ij}(i,:));
    
        ConMatrix(1,i) = min(Low_Con_Stat{1,ij}(i,:));
        ConMatrix(2,i) = mean(Low_Con_Stat{1,ij}(i,:));
        ConMatrix(3,i) = max(Low_Con_Stat{1,ij}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'k','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'k','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    plot(tspan,ConMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (Day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    if ij == 1
        ylabel('Neutrophil')
    elseif ij == 2
        ylabel('Monocyte')
    elseif ij == 3
        ylabel('M1')
    elseif ij == 4
        ylabel('M2')
    elseif ij == 5
        ylabel('Pathogen')
    elseif ij == 6
        ylabel('S2')
    else
        ylabel('S6')
    end

end


%%%% Uncontrolled Healthy and Unhealthy
figure(3)
for ij = 1:4
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(Low_UnCon{1,ij}(i,:));
        UnMatrix(2,i) = mean(Low_UnCon{1,ij}(i,:));
        UnMatrix(3,i) = max(Low_UnCon{1,ij}(i,:));
    
        ConMatrix(1,i) = min(High_UnCon{1,ij}(i,:));
        ConMatrix(2,i) = mean(High_UnCon{1,ij}(i,:));
        ConMatrix(3,i) = max(High_UnCon{1,ij}(i,:));
    end
    subplot(2,4,ij)
    %plot(tspan,UnMatrix(2,:),'Color','#77AC30','LineWidth',2)
    plot(tspan,UnMatrix(2,:),'Color','k','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'k','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    plot(tspan,ConMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    if ij == 1
        ylabel('Neutrophil')
    elseif ij == 2
        ylabel('Monocyte')
    elseif ij == 3
        ylabel('M1')
    elseif ij == 4
        ylabel('M2')
    elseif ij == 5
        ylabel('Pathogen')
    elseif ij == 6
        ylabel('IL-6')
    else
        ylabel('TNF-\beta')
    end

end


for ij = 5
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(Low_UnCon{1,ij}(i,:));
        UnMatrix(2,i) = mean(Low_UnCon{1,ij}(i,:));
        UnMatrix(3,i) = max(Low_UnCon{1,ij}(i,:));
    
% %         ConMatrix(1,i) = min(High_UnCon{1,ij}(i,:));
% %         ConMatrix(2,i) = mean(High_UnCon{1,ij}(i,:));
% %         ConMatrix(3,i) = max(High_UnCon{1,ij}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'Color','k','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'k','FaceAlpha',0.1,'EdgeColor','none');
    hold on


    xlabel('Time (day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    
        ylabel('log(Pathogen)')
    

end

for ij = 6
    for i = 1:length(tspan)
        
        ConMatrix(1,i) = min(High_UnCon{1,ij-1}(i,:));
        ConMatrix(2,i) = mean(High_UnCon{1,ij-1}(i,:));
        ConMatrix(3,i) = max(High_UnCon{1,ij-1}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,ConMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on


    xlabel('Time (day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    
    ylabel('log(Pathogen)')
    

end

for ij = 7:8
    for i = 1:length(tspan)
        UnMatrix(1,i) = min(Low_UnCon{1,ij-1}(i,:));
        UnMatrix(2,i) = mean(Low_UnCon{1,ij-1}(i,:));
        UnMatrix(3,i) = max(Low_UnCon{1,ij-1}(i,:));
    
        ConMatrix(1,i) = min(High_UnCon{1,ij-1}(i,:));
        ConMatrix(2,i) = mean(High_UnCon{1,ij-1}(i,:));
        ConMatrix(3,i) = max(High_UnCon{1,ij-1}(i,:));
    end
    subplot(2,4,ij)
    plot(tspan,UnMatrix(2,:),'Color','k','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [UnMatrix(1,:),fliplr(UnMatrix(3,:))];
    fill(tx,py,'k','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    plot(tspan,ConMatrix(2,:),'r','LineWidth',2)
    hold on
    tx = [tspan,fliplr(tspan)];
    py = [ConMatrix(1,:),fliplr(ConMatrix(3,:))];
    fill(tx,py,'r','FaceAlpha',0.1,'EdgeColor','none');
    hold on

    xlabel('Time (day)')  
    xlim([0 8])  
    set(gca,'FontName','Times New Roman')
    set(gca,'FontSize',24)
    if ij == 7
        ylabel('IL-6')
    else
        ylabel('TNF-\beta')
    end

end

