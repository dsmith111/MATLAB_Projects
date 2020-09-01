clf
clear
figure(1)
clf
hold on;

testcount=0;
%Emotion Array
eMat=zeros(1,10000);
%Hunger Array
hMat=zeros(1,10000);
%Health Array
hlMat=zeros(1,10000);
%Age Array
aMat=zeros(1,10000);
%Border (Listed as 5)
mBorder = zeros(60);
mBorder(:,1) = 5;
mBorder(1,:) = 5;
mBorder(end,:) = 5;
mBorder(:,end) = 5;
border = 5;
%Blank Map
newMap = zeros(length(mBorder),length(mBorder),2);
% Grass (Listed as 2)
mGrass = (rand(length(mBorder))>0.98)*2;
mGrass(:,1) = 0;
mGrass(1,:) = 0;
mGrass(end,:) = 0;
mGrass(:,end) = 0;
grass = 2;
%Combine Matrices
mWorld(:,:,1) = mGrass + mBorder;
newMap(:,:,1) = newMap(:,:,1) + mBorder;
% Herbivores (Listed as 3)
mHerbivores = (rand(length(mBorder))>0.99)*3;
mHerbivores(:,1) = 0;
mHerbivores(1,:) = 0;
mHerbivores(end,:) = 0;
mHerbivores(:,end) = 0;
herbivore = 3;
%Predators (Listed as 4)
mPredators = (rand(length(mBorder))>0.996)*4;
mPredators(:,1) = 0;
mPredators(1,:) = 0;
mPredators(end,:) = 0;
mPredators(:,end) = 0;
predator = 4;
% Add Creatures to world matrix
%Herb
for i = 1:numel(mWorld(:,:,1))
    
    if(mWorld(i) ~= border && mWorld(i) ~= grass)
        mWorld(i) = mHerbivores(i);
    end
    
end
%Pred
for i = 1:numel(mWorld(:,:,1))
    
    if(mWorld(i) ~= border && mWorld(i) ~= grass && mWorld(i) ~= herbivore)
        mWorld(i) = mPredators(i);
    end
    
end
%
% Generate initial world plot
bcount=1;
bxc=0;
byr=0;
for i = 1:length(mWorld)
    
    for j =1:length(mWorld)
        if(mWorld(i,j) == border)
            scatter(i,j,"black",'filled','Marker','s')
            bxc(bcount)=i;
            byr(bcount)=j;
            bcount = bcount+1;
        elseif(mWorld(i,j) == grass)
            scatter(i,j,"green",'Marker','^');
        elseif(mWorld(i,j) == herbivore)
            scatter(i,j,"blue",'marker','*')
        elseif(mWorld(i,j) == predator)
            scatter(i,j,'red','marker','x')
        end
    end
    drawnow
end
%Set UIDs
aCount=0;
for i= 1:numel(mWorld(:,:,1))
    if(mWorld(i) ==3)
        %If Herbivore is discovered, add UID, add to count & add to list.
        [tr, tc] =ind2sub([length(mWorld) length(mWorld)],i);
        aCount = aCount +1;
        mWorld(tr,tc,2) = aCount;
        
    elseif(mWorld(i) == 4)
        %If Predator is discovered, do the same as above
        [tr, tc] =ind2sub([length(mWorld) length(mWorld)],i);
        aCount = aCount +1;
      
         mWorld(tr,tc,2) = aCount;
           elseif(mWorld(i) == 5)
        %If Border is discovered, do the same as above
        [tr, tc] =ind2sub([length(mWorld) length(mWorld)],i);
        aCount = aCount +1;
      
         mWorld(tr,tc,2) = aCount;
           elseif(mWorld(i) == 2)
        %If grass is discovered, do the same as above
        [tr, tc] =ind2sub([length(mWorld) length(mWorld)],i);
        aCount = aCount +1;
      
         mWorld(tr,tc,2) = aCount;
         
         
        
        
    end
    %UIDs will be assigned as such

end
% Set Hunger & Emotion to 1 ((full vs starving) and (content vs fear-ridden) and health for each living creature
for i= 1:numel(mWorld(:,:,2))
    [tr, tc] = ind2sub([length(mWorld) length(mWorld)],i);
    if(mWorld(tr,tc,2) ~= 0)
        hMat(mWorld(tr,tc,2)) = 1;
        eMat(mWorld(tr,tc,2)) = .9;
        hlMat(mWorld(tr,tc,2)) = 1;
    end
end
maturityAge=25;
%Steps for Sim loop
% A. Check Stats
    % 1. Determine Hunger
    % 2. Determine Emotion
    % 3. Tiredness
    % 4. Health
% B. Determine Action
    % 1.Eat
    % 2.Flee
    % 3.Sleep
    % 4.Group
    % 5.Wander
    % 6.Attack
    % 7.Hunt
    % 8.Defend
    % 9.Reproduce
    
%     Run Simulation
for k = 1:3200
    herbMat =[];
    predMat =[];
    grassMat =[];
    borderMat =[];
    carcassMat =[]; %These matrices are meant for graphical purposes (Drawing map)
    %amountOfCreatures=numel(find(mWorld(:,:,2)~=0)); %Instance of simulation will run for each living creature
   hMat= hMat -.02;
        
   
   tic

    for i = 1:numel(mWorld(:,:,1))
        skip=false;
        testcount = testcount+1;
        xInd = find(mWorld(:,:,2) == i); %Find Index
        if(sum(xInd(:))==0)
            continue;
        end
        oLoc = [0 0]; %Set variable as Array
        [oLoc(1), oLoc(2)] = ind2sub([length(mWorld) length(mWorld)],xInd); %Place coordinates of current creature in vector
        
        cUID = mWorld(oLoc(1),oLoc(2),2); %Grabbing Creature Unique ID
        type = mWorld(oLoc(1),oLoc(2),1); %Grabbing Creature Type

        if( hMat(cUID) <0)
            hMat(cUID)=0;
        end
        if(hlMat(cUID)<0)
            hlMat(cUID)=0;
        end
        if(type==1.5)
           aMat(cUID)= aMat(cUID)+1;
           if(aMat(cUID)>=20)
                mWorld(oLoc(1),oLoc(2),1) = 2; %Fertilizes
                newMap(oLoc(1),oLoc(2),1)=2;
                type = 2;
           end
        end
        if((type ==3) || (type ==4)) %Is this a creature
            if((aMat(cUID)~=900) && (aMat(cUID)~=999))
            aMat(cUID) = aMat(cUID)+1;
            end
            if(hMat(cUID)<=0) %If hunger is zero, health decreases
              hlMat(cUID)=hlMat(cUID)-.05;  
            end
          
            if(hlMat(cUID)<=0) %If creature health is 0 or less. Change to carcass
                if(type==3)
                mWorld(oLoc(1),oLoc(2),1) = 2.5; %2.5 represents carcass
                newMap(oLoc(1),oLoc(2),1)=2.5;
                type = 2.5;
                elseif(type==4)
                mWorld(oLoc(1),oLoc(2),1) = 1.5; %1.5 represents p carcass
                newMap(oLoc(1),oLoc(2),1)= 1.5;
                type = 1.5;
                aMat(cUID) =0;
                
                end
                
                %mWorld(oLoc(1),oLoc(2),2) = 0;   % Remove UID
                skip=true;
            end
            
            if(skip==false)
            %Look around
           [friendcount,frienddist,frLoc,enemycount,enemydist,enLoc,eUID,foodcount,fooddist,fLoc,aLoc,aUID]= sight(mWorld,cUID,aMat,maturityAge);
           
           %Process Emotion
           [nE] = emotion(eMat, hMat,frienddist,enemydist,friendcount,enemycount,foodcount,hlMat,cUID);
            
           %Think about what to do
           action=think(mWorld,cUID,eMat,hMat,fooddist,enemydist,hlMat,enemycount,foodcount,aMat,aUID,maturityAge);
           
           %Perform action
           [foodEaten,hlMat,newMap,hMat,aCount,aMat,eMat] = act(hMat,cUID,mWorld,enemydist,fooddist,hlMat,action,enLoc,fLoc,eUID,type,newMap,aCount,aLoc,aUID,aMat,eMat);
           if(foodEaten == true)
             if((mWorld(fLoc(1),fLoc(2),1)==2.5) || (mWorld(fLoc(1),fLoc(2),1)==2))
               mWorld(fLoc(1),fLoc(2),1) = 0;
               mWorld(fLoc(1),fLoc(2),2) = 0;
             end
               if(newMap(fLoc(1),fLoc(2),1) == 2.5 || (newMap(fLoc(1),fLoc(2),1) == 2))
                newMap(fLoc(1),fLoc(2),1) = 0;
                newMap(fLoc(1),fLoc(2),2) = 0;
              end
           end
           
           
            end
        end
       switch type
           case 3
               herbMat =cat(1,herbMat,oLoc);
               
           case 4
              predMat= cat(1,predMat,oLoc);
               
           case 2
             if(cUID~=0)  
               grassMat=   cat(1,grassMat,oLoc);
                newMap(oLoc(1),oLoc(2),2)=cUID;
                newMap(oLoc(1),oLoc(2),1)=type;
             end
           case 2.5
            if(cUID~=0)
               carcassMat=  cat(1,carcassMat,oLoc);
              newMap(oLoc(1),oLoc(2),2)=cUID;
              newMap(oLoc(1),oLoc(2),1)=type;
            end
             case 1.5
            if(cUID~=0)
               carcassMat=  cat(1,carcassMat,oLoc);
              newMap(oLoc(1),oLoc(2),2)=cUID;
              newMap(oLoc(1),oLoc(2),1)=type;
            end
           case 5
               if(cUID~=0)
                borderMat= cat(1,borderMat,oLoc);
                newMap(oLoc(1),oLoc(2),2)=cUID;
                newMap(oLoc(1),oLoc(2),1)=type;
               end
       end
       
       
    end
    if(length(grassMat)<500)
    %    Regenerate Trees
for l = 1:randi([1,5])
    empty = false;
    while empty == false
   r = randi([2,length(mWorld)-1]);
   c = randi([2,length(mWorld)-1]);
     if(newMap(r,c) == 0)
         aCount =aCount+1;
        grassMat=   cat(1,grassMat,[r c]);
         newMap(r,c,2)=aCount;
         newMap(r,c,1)=2;
       empty=true;
     end
    end
end
    end
    toc
        %Regen Creatures
     if(length(predMat)<=2)
       for l = 1:randi([5,10])
    empty = false;
    while empty == false
   r = randi([2,length(mWorld)-1]);
   c = randi([2,length(mWorld)-1]);
     if(newMap(r,c) == 0)
         aCount =aCount+1;
        predMat=   cat(1,predMat,[r c]);
         newMap(r,c,2)=aCount;
         newMap(r,c,1)=4;
                 hMat(aCount)=1;
        hlMat(aCount)=1;
        eMat(aCount)=1;
        aMat(aCount)=0;
       empty=true;
     end
    end
       end
     end
   if(length(herbMat)<=2)
        for l = 1:randi([5,10])
    empty = false;
    while empty == false
   r = randi([2,length(mWorld)-1]);
   c = randi([2,length(mWorld)-1]);
     if(newMap(r,c) == 0)
         aCount =aCount+1;
        herbMat=   cat(1,herbMat,[r c]);
         newMap(r,c,2)=aCount;
         newMap(r,c,1)=3;
                 hMat(aCount)=1;
        hlMat(aCount)=1;
        eMat(aCount)=1;
        aMat(aCount)=0;
       empty=true;
     end
    end
        end

    end
       
    herbTrack(k,1)=numel(herbMat);
    herbTrack(k,2)=k;
    grassTrack(k,1)=numel(grassMat);
    grassTrack(k,2)=k;
    predTrack(k,1)=numel(predMat);
    predTrack(k,2)=k;
    

 
    redraw(mWorld,herbMat,predMat,grassMat,carcassMat,borderMat,herbTrack,grassTrack,predTrack);
    drawnow
    mWorld = newMap;
    newMap = zeros(length(mWorld),length(mWorld),2);
    %newMap(:,:,1) = newMap(:,:,1) + mBorder;
    
    
    
end
%Redraw Map
function redraw(mWorld,herbMat,predMat,grassMat,carcassMat,borderMat,hcount,gcount,pcount)
figure(1)  
hold off;
    scatter(1,1,'marker','none');
    hold on;
    scatter(length(mWorld),length(mWorld),'marker','none');
    %Plot initial map
    
    
    if(sum(predMat(:))~=0)
    % Pred
    scatter(predMat(:,2),predMat(:,1),'red','marker','x')
    end
    
    if(sum(grassMat(:))~=0)
    %  Grass
    scatter(grassMat(:,2),grassMat(:,1),'green','marker','^')
    end
    
    if(sum(herbMat(:))~=0)
    %   Herb
    
    scatter(herbMat(:,2),herbMat(:,1),'blue','marker','*')
    end
    
    if(sum(carcassMat(:))~=0)
    %   Carcass
    scatter(carcassMat(:,2),carcassMat(:,1),'black','marker','x')
    end
    
    if(sum(borderMat(:))~=0)
    %  Border
    scatter(borderMat(:,2),borderMat(:,1),'black','filled','Marker','s')
    end
    
    figure(2)
    hold on;
    plot(hcount(:,2),hcount(:,1),'b');
    title('Population Count');
    xlabel('Years');
    ylabel('Amount')
%     plot(gcount(:,2),gcount(:,1),'g');
    plot(pcount(:,2),pcount(:,1),'r');
    
    legend('Herbivores','Predators')%,'Plants')
    % end
    %drawnow
end
%function for processing emotion
function [nE] =emotion(eMat, hMat,frienddist,enemydist,friendcount,enemycount,foodcount,hlMat,UID)
    %Weight for each input on emotion
    hungerWeight = 0.07;
    healthWeight = .33;
    nearCreatureWeight = 0.40;
    nearFoodWeight = .05;%*(1+hungerWeight);
    distCreatureWeight = .15;
    
    distCreature = frienddist/enemydist;
    if(distCreature==inf)
        distCreature=1;
    end
    distCreature = distCreature-1;
    nearCreature = friendcount/enemycount;
    if(enemycount==0)
        nearCreature=1;
    end
    nearCreature=nearCreature-1;
    
    
    %Combine weights to emotion
    cHl = hlMat(UID);
    cE= eMat(UID);
    cH = hMat(UID);
%     .6 in line are threshold values
    pEmotion = ((hungerWeight*(cH-.6))+(healthWeight*(cHl-.6))+(nearCreature*nearCreatureWeight)...
        +(((foodcount/48)*nearFoodWeight))+(distCreature*distCreatureWeight));
    nE = cE+pEmotion;
      if(nE>1)
            nE=1;
      elseif(nE<0)
          nE=0;
      end
end
    
%function for Seeing
function[friendcount,frienddist,frLoc,enemycount,enemydist,enLoc,eUID,foodcount,fooddist,fLoc,aLoc,aUID]= sight(mWorld,UID,aMat,age)



    sCardinal = 8;
    cIX = find(mWorld(:,:,2)==UID);
    [tr,tc] = ind2sub([length(mWorld) length(mWorld)], cIX);
    type = mWorld(tr,tc,1);
    switch type
        case 3
            sRange = 12;
        case 4
            sRange = 14;
    end
    oLoc = [tr tc];
    eUID=0;
    %Determine distance,type and count of everything in range
    pcount=0;
    hcount=0;
    fcount=0;
    pdist=inf;
    hdist=inf;
    fdist=inf;
    aUID =0;
    aLoc=[inf inf];
    %A loop is used to scan everything within a 7x7 area
%         The norm function is used to determine distances. Everytime an
%         object is found it is counted and its distance from the local
%         origin is recorded.
    for i = -sRange:sRange
        for j = -sRange:sRange
            if(((tr+i)<=0) ||((tc+j)<=0) || ((tr+i)>length(mWorld)) ||((tc+j)>length(mWorld)))
                continue;
            end
            xLoc = [(tr+i) (tc+j)];
           
            %grass
            if(mWorld(tr+i,tc+j,1)== 2)
                if(type ==3)
                    fcount = fcount +1;
                        if(norm(xLoc-oLoc)<fdist)
                            fdist = norm(xLoc-oLoc);
                            fLoc=xLoc;
                        end
                end
                %dead herb
            elseif(mWorld(tr+i,tc+j,1)== 2.5)
                if(type==4)
                 fcount = fcount+1;
                  if(norm(xLoc-oLoc)<fdist)
                    fdist = norm(xLoc-oLoc);
                    fLoc=xLoc;
                  end
                end
                  %herb
            elseif(mWorld(tr+i,tc+j,1)== 3)
                hcount = hcount+1;
                     if((norm(xLoc-oLoc)<hdist)&&(norm(xLoc-oLoc)~=0))
                        hdist = norm(xLoc-oLoc);
                        hLoc=xLoc;
                        if((aMat(mWorld(hLoc(1),hLoc(2),2))>=age) &&(type ==3)&&(aMat(mWorld(hLoc(1),hLoc(2),2))~=900))
                           aLoc=hLoc;
                           aUID=mWorld(hLoc(1),hLoc(2),2);
                        end
                     end
                
            %pred
            elseif(mWorld(tr+i,tc+j,1)== 4)
                 pcount = pcount+1;
                  if((norm(xLoc-oLoc)<pdist)&&(norm(xLoc-oLoc)~=0))
                    pdist = norm(xLoc-oLoc);
                    pLoc=xLoc;
                        if((aMat(mWorld(pLoc(1),pLoc(2),2))>=age) &&(type ==4)&&(aMat(mWorld(pLoc(1),pLoc(2),2))~=900))
                           aLoc=pLoc;
                           aUID=mWorld(pLoc(1),pLoc(2),2);
                        end
                  end
            end
        end
    end
    
    if(hcount ==0)
        hLoc = [inf inf];
        hdist = inf;
    end
    if(pcount==0)
        pLoc = [inf inf];
        pdist = inf;
    end
    if(fcount==0)
        fLoc = [inf inf];
        fdist = inf;
    end
    
   if(type==3)
           if(hcount <=1)
        hLoc = [inf inf];
        hdist = inf;
            end
       friendcount=hcount-1;
       enemycount=pcount;
       foodcount=fcount;
       frienddist=hdist;
       frLoc=hLoc;
       enemydist=pdist;
       enLoc=pLoc;
       fooddist=fdist;
       if(pcount~=0)
         eUID= mWorld(enLoc(1),enLoc(2),2);
       else
           eUID=0;
       end
   elseif(type==4)
           if(pcount<=1)
        pLoc = [inf inf];
        pdist = inf;
            end
        friendcount=pcount-1;
       enemycount=hcount;
       foodcount=fcount;
       frienddist=pdist;
       frLoc=pLoc;
       enemydist=hdist;
       enLoc=hLoc;
       fooddist=fdist;
       if(hcount ~=0)
         eUID= mWorld(enLoc(1),enLoc(2),2);
       else
           eUID=0;
       end
   end
end
            
%function for deciding action
function action=think(mWorld,UID,eMat,hMat,fooddist,enemydist,hlMat,enemycount,foodcount,aMat,aUID,age)
%    Can move, attack, eat or rest
    action = "wander";
    cE = eMat(UID);
    cH = hMat(UID);
    cHl = hlMat(UID);
    hhungerThresh = .33;
    hhealthThresh =.65;
    hemotionThresh=.75;
    phungerThresh = .55;
    phealthThresh =.45;
    pemotionThresh=.25;
    
     cIX = find(mWorld(:,:,2)==UID);
    [tr,tc] = ind2sub([length(mWorld) length(mWorld)], cIX);
    type = mWorld(tr,tc,1); %Type 3 is herb, 4 is pred
    
%Will Rest if health is lower than hunger if food is in range, or if hunger is
%over a threshold and there is no food in sight (and no enemies)
% Will move if high health and low food meter and there is no food, if there is an
% enemy present, if food meter 
%Will attack if enemy is adjacent, health is above threshold, and emotion
%is above threshold
%Will eat if food is adjacent, hunger is less than one, there are no
%enemies and is not resting
% *****Are we pred or herb
    if(type==3)
        
        %Should we rest, eat, wander, attack
        %Reproduce
        if((aMat(UID)>=age)&&(enemycount==0)&&(cHl>hhealthThresh)&&(cH>hhungerThresh)&&(cE>hemotionThresh)&& (aUID ~=0)&&(aMat(UID)~=900))
            action ='rep';
        
        %Rest
        elseif((((cHl<cH)&& (foodcount~=0) )||((cH>hhungerThresh)&& (foodcount==0)))&&(enemycount==0)&&(cHl<hhealthThresh))
            action ='rest';
        
        %eat
        elseif((cH<1)&&(enemycount==0)&&(foodcount>=1))
            action='eat';
        
        
        %Attack
        elseif((enemycount>=1)&&(cHl>hhealthThresh)&&(cE>hemotionThresh)&&(enemydist<=3))
            action='attack';
        
        %Flee
        elseif(((cHl<hhealthThresh)||(cE<hemotionThresh))&&(enemycount>=1))
            action='flee';
        
        %Wander
        else
            action='wander';
        end
       
    
    end
     if(type==4)
        
        %Should we rest, eat, wander, attack 
        
        %Reproduce
        if((aMat(UID)>=age)&&(enemydist>=3)&&(cHl>phealthThresh)&&(cH>phungerThresh)&&(cE>pemotionThresh)&& (aUID ~=0)&&(aMat(UID)~=900))
            action ='rep';
        
        %Rest
        elseif((((cHl<cH)&& (foodcount~=0) )||(cH>phungerThresh)&& (foodcount==0))&&(enemydist>=2)&&(cHl<phealthThresh))
            action ='rest';
        

        %eat
        elseif((cH<1)&&(enemydist>=2)&&(foodcount>=1))
            action='eat';
        
        
        %Attack
        elseif((enemycount>=1)&&(cHl>phealthThresh)&&(cE>pemotionThresh)&&(foodcount<3)&&(cH<=(phungerThresh+.11)))
            action='attack';
        %Flee
        elseif(((cHl<phealthThresh)||(cE<pemotionThresh)&&(enemycount>=1)))
            action='flee';
        
        %wander
        else
            action='wander';
        end
       
    
    end
end
%function for performing action
function [foodEaten,hlMat,newMap,hMat,aCount,aMat,eMat]=act(hMat,UID,mWorld,enemydist,fooddist,hlMat,action,enLoc,fLoc,eUID,type,newMap,aCount,aLoc,aUID,aMat,eMat)
    %Possiblities: Move toward,flee,eat,attack,wander,rest
    cIX = find(mWorld(:,:,2)==UID);
    [tr,tc] = ind2sub([length(mWorld) length(mWorld)], cIX);
    oLoc = [tr tc];
    cHl=hlMat(UID);
    nLoc = oLoc;
    if(enemydist ~= inf)
        eHl=hlMat(eUID);
    end
    cH=hMat(UID);
    pDam=.10;
    hDam=.01;
    foodEaten = false;
   
    %Attack
    if(strcmpi(action,'attack'))
        %If enemy is next to, attack
        if(norm(oLoc-enLoc)==1)
        %Pred attack
            if(type==4)
                eHl=eHl-pDam;
                hlMat(eUID)=eHl;
        %Herb attack    
            elseif(type==3)
                eHl=eHl-hDam;
                hlMat(eUID)=eHl;
            end
        end
        %If enemy is not next to, move closer
        if((norm(oLoc-enLoc)>1))    
            for i= -1:1
                for j=-1:1
                    dLoc = [(oLoc(1)+i) (oLoc(2)+j)];
                    if((norm(dLoc-enLoc)<enemydist)&&(newMap(dLoc(1),dLoc(2))==0)&&(mWorld(dLoc(1),dLoc(2))==0))
                        enemydist=norm(dLoc-enLoc);
                        nLoc = dLoc;
                    end
                    
                end
            end 
        end
        newMap(nLoc(1),nLoc(2),2)=UID;
        newMap(nLoc(1),nLoc(2),1)=type;
        
        %Rep
    elseif(strcmpi(action,'rep'))
      
          %If friend is next to, rep
        if((norm(oLoc-aLoc)==1)&&(aMat(aUID)>=999)&& (aMat(aUID)~=900))
        %rep
        prod = randi([2 5]);
          for f = 1:prod
               repStatus=false;
          pathSel = false;
        count =0;
        while(pathSel == false)
                   
            nLoc(1) = nLoc(1)+randi([-1 1]);
            nLoc(2) = nLoc(2)+randi([-1 1]);
            if ((nLoc(1)<=0)||(nLoc(2)<=0) || (nLoc(1)>=length(mWorld)) || (nLoc(2) >= length(mWorld)))
                count=count+1;
                if(count>=8)
                    repStatus = false;
                    pathSel=true;
                end
                continue;
            end
            if((mWorld(nLoc(1),nLoc(2))==0)&&(newMap(nLoc(1),nLoc(2))==0))
                pathSel = true;
                repStatus = true;
            end
        end
        
        aMat(aUID) = 0;
        aMat(UID) = -5;
        newMap(oLoc(1),oLoc(2),2)=UID;
        newMap(oLoc(1),oLoc(2),1)=type;
        if(repStatus == true)
            aCount=aCount+1;
        newMap(nLoc(1),nLoc(2),2)=aCount;
        newMap(nLoc(1),nLoc(2),1)=type;
        hMat(aCount)=1;
        hlMat(aCount)=1;
        eMat(aCount)=1;
        aMat(aCount)=0;
        end
          end
        elseif((aMat(aUID) ~= 999)&&(norm(oLoc-aLoc)==1))
            aMat(UID) = 999;
            newMap(oLoc(1),oLoc(2),2)=UID;
            newMap(oLoc(1),oLoc(2),1)=type;
         
        end
        %If mate is not next to, move closer
        if((norm(oLoc-aLoc)>1))    
            adist = norm(oLoc-aLoc);
            for i= -1:1
                for j=-1:1
                    dLoc = [(oLoc(1)+i) (oLoc(2)+j)];
                    
                    if((norm(dLoc-aLoc)<adist)&&(newMap(dLoc(1),dLoc(2))==0)&&(mWorld(dLoc(1),dLoc(2))==0))
                        adist=norm(dLoc-aLoc);
                        nLoc = dLoc;
                    end
                    
                end
            end
         newMap(nLoc(1),nLoc(2),2)=UID;
         newMap(nLoc(1),nLoc(2),1)=type;
        end

        
    %Eat
    elseif(strcmpi(action,'eat'))
          %If food is next to, eat
        if(norm(oLoc-fLoc)==1)
        %StartEating
        if(type==3)
                cH=cH+(.15);
        elseif(type==4)
                cH=cH+(.85);
        end
                if(cH>1)
                    cH=1;
                end   
                foodEaten = true;
                hMat(UID)=cH;
            
        end
        %If food is not next to, move closer
        if(norm(oLoc-fLoc)>1)    
            for i= -1:1
                for j=-1:1
                    dLoc = [(oLoc(1)+i) (oLoc(2)+j)];
                    if((norm(dLoc-fLoc)<fooddist)&&(mWorld(dLoc(1),dLoc(2))==0)&&(newMap(dLoc(1),dLoc(2))==0))
                       fooddist = norm(dLoc-fLoc);
                        nLoc = dLoc;
                    end
                    
                end
            end
        end
            newMap(nLoc(1),nLoc(2),2)=UID;
            newMap(nLoc(1),nLoc(2),1)=type;
    elseif(strcmpi(action,'rest'))
        %Heal
        cHl = cHl+.05;
        if(cHl>1)
        cHl=1;
        end
            newMap(nLoc(1),nLoc(2),2)=UID;
            newMap(nLoc(1),nLoc(2),1)=type;
        %Wander    
    elseif(strcmpi(action,'wander'))
        
        %Random Walk
        pathSel = false;
        count =0;
        while(pathSel == false)
                   
            nLoc(1) = nLoc(1)+randi([-1 1]);
            nLoc(2) = nLoc(2)+randi([-1 1]);
            if ((nLoc(1)<=0)||(nLoc(2)<=0) || (nLoc(1)>=length(mWorld)) || (nLoc(2) >= length(mWorld)))
                count=count+1;
                if(count>=8)
                    nLoc=oLoc;
                    pathSel=true;
                end
                continue;
            end
            if((mWorld(nLoc(1),nLoc(2))==0)&&(newMap(nLoc(1),nLoc(2))==0))
                pathSel = true;
            end
        end
        newMap(nLoc(1),nLoc(2),2)=UID;
        newMap(nLoc(1),nLoc(2),1)=type;
        
        
        %Flee    
    elseif(strcmpi(action,'flee'))
        %Flee away from closest enemy
        count = 0;
        
            for i= -1:1
                if((type==3) && (enemydist==1))
                    nLoc=oLoc;
                    break;
                end
                for j=-1:1
                    dLoc = [(oLoc(1)+i) (oLoc(2)+j)];
                    if((norm(dLoc-enLoc)>enemydist)&&(mWorld(dLoc(1),dLoc(2))==0)&&(newMap(dLoc(1),dLoc(2))==0))
                        if(count==0)
                            nLoc=dLoc;
                            count=1;
                            continue;
                        end
                        if((norm(dLoc-enLoc)>enemydist)&&(mWorld(dLoc(1),dLoc(2))==0)&&(newMap(dLoc(1),dLoc(2))==0))
                            enemydist= norm(dLoc-enLoc);
                            nLoc=dLoc;
                        end
                    end
                    
                end
            end
        newMap(nLoc(1),nLoc(2),2)=UID;
        newMap(nLoc(1),nLoc(2),1)=type;
    end
   
end

