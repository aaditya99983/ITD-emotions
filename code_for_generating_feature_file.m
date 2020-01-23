global numofpeaks;
for i=1:22
in_file=sprintf('Data_files/U%d_LIHF_itd_file.csv',i);

fp=fopen(in_file);
cell=textscan(fp,'%d %s %f %d %d %s %d %d','Delimiter',',');        
fclose(fp);
%whos cell
cell
numofpeaks=15;
Write_filename=sprintf('Training_files_v4/%d/%s_%d_v4.csv', numofpeaks, 'user',i);
session_no=cell{1,1};
happy_itd={};
happy_time={};
sad_itd={};
sad_time={};
stressed_itd={};
stressed_time={};
relaxed_itd={};
relaxed_time={};
unique_session_no=unique(session_no);
%d=length(unique_session_no);
for i=1:length(unique_session_no)
    current_id=unique_session_no(i);
    list_itd=cell{1,3}(cell{1,1}(:)==current_id);
    if(length(list_itd)>=3)
    if(cell{1,5}(cell{1,1}(:)==current_id)==2)
        happy_itd=[happy_itd,{real(fft(list_itd))}];
        happy_time=[happy_time, list_itd];
%         list_itd
%         happy_itd
    end
    
    if(cell{1,5}(cell{1,1}(:)==current_id)==-2)
        sad_itd=[sad_itd,{real(fft(list_itd))}];
        sad_time=[sad_time, list_itd];
    end
    if(cell{1,5}(cell{1,1}(:)==current_id)==1)
        stressed_itd=[stressed_itd,{real(fft(list_itd))}];
        stressed_time=[stressed_time, list_itd];
    end
    if(cell{1,5}(cell{1,1}(:)==current_id)==0)
        relaxed_itd=[relaxed_itd,{real(fft(list_itd))}];
        relaxed_time=[relaxed_time, list_itd];
    end
    end
end


[max_happy_length,max_happy_index]= max(cellfun('size',happy_itd,1));

[max_sad_length,max_sad_index]= max(cellfun('size',sad_itd,1));
[max_stressed_length,max_stressed_index]= max(cellfun('size',stressed_itd,1));
[max_relaxed_length,max_relaxed_index]= max(cellfun('size',relaxed_itd,1));

n_happy = cellfun(@numel,happy_itd);
out_happy = cellfun(@(x,y)[x(:);zeros(max(n_happy)-y,1)],happy_itd,num2cell(n_happy),'un',0);
out_happyt = cellfun(@(x,y)[x(:);zeros(max(n_happy)-y,1)],happy_time,num2cell(n_happy),'un',0);
%whos out_happy
n_sad = cellfun(@numel,sad_itd);
out_sad = cellfun(@(x,y)[x(:);zeros(max(n_sad)-y,1)],sad_itd,num2cell(n_sad),'un',0);
out_sadt = cellfun(@(x,y)[x(:);zeros(max(n_sad)-y,1)],sad_time,num2cell(n_sad),'un',0);
%disp(out_sad)

n_stress = cellfun(@numel,stressed_itd);
out_stress = cellfun(@(x,y)[x(:);zeros(max(n_stress)-y,1)],stressed_itd,num2cell(n_stress),'un',0);
out_stresst = cellfun(@(x,y)[x(:);zeros(max(n_stress)-y,1)],stressed_time,num2cell(n_stress),'un',0);

%disp(out_stress)
n_relax = cellfun(@numel,relaxed_itd);
out_relax = cellfun(@(x,y)[x(:);zeros(max(n_relax)-y,1)],relaxed_itd,num2cell(n_relax),'un',0);
out_relaxt = cellfun(@(x,y)[x(:);zeros(max(n_relax)-y,1)],relaxed_time,num2cell(n_relax),'un',0);
%disp(out_relax)
% measure_coherence_same(out_happy,out_happy,Write_filename,2);
% measure_coherence_same(out_sad,out_sad,Write_filename,-2);
% measure_coherence_same(out_stress,out_stress,Write_filename,1);
% measure_coherence_same(out_relax,out_relax,Write_filename,0);
% measure_peakFreq(out_happy,Write_filename,2);
% measure_peakFreq(out_sad,Write_filename,-2);
% measure_peakFreq(out_stress,Write_filename,1);
% measure_peakFreq(out_relax,Write_filename,0);
measure_3Freq3Amp(out_happy,Write_filename,2);
measure_3Freq3Amp(out_sad,Write_filename,-2);
measure_3Freq3Amp(out_stress,Write_filename,1);
measure_3Freq3Amp(out_relax,Write_filename,0);
% measure_coherence_same_with_time(out_happy,out_happy,out_happyt,out_happyt ,Write_filename,2);
% measure_coherence_same_with_time(out_sad,out_sad,out_sadt,out_sadt, Write_filename,-2);
% measure_coherence_same_with_time(out_stress,out_stress,out_stresst,out_stresst, Write_filename,1);
% measure_coherence_same_with_time(out_relax,out_relax,out_relaxt,out_relaxt,Write_filename,0);
end



function measure_coherence_same(a,b,filename,code)
    Fs=1e3;
    spec=[];
    fileid=fopen(filename,'a');
    for i=1:size(a,2)
        for j=i+1:size(b,2)
            [Cxy,f] = mscohere(a{1,i},b{1,j},[],[],[],Fs);

            [pks,locs,w,p] = findpeaks(Cxy,'SortStr','descend','NPeaks',3);
            p=f(locs);
            diff = abs([p(1)-p(2), p(2)-p(3)]);
            MatchingFreqs = [reshape(p,1,3),reshape(pks,1,3),reshape(diff,1,2)];
            
%             MatchingFreqs=MatchingFreqs.';
            %whos MathchingFreqs
            spec=[spec;MatchingFreqs];
                
        end

    end
    %whos spec
    write_spec=unique(spec,'rows');
    %whos write_spec
    write_spec;
    for k=1:size(write_spec,1)
        fprintf(fileid,'%f,%f,%f,%f,%f,%f,%f,%f,%d\n',write_spec(k,1),write_spec(k,2),write_spec(k,3),write_spec(k,4),write_spec(k,5),write_spec(k,6),write_spec(k,7),write_spec(k,8),code);
    end

    fclose(fileid);
end

function measure_coherence_same_with_time(a,b,ta,tb,filename,code)
    Fs=1e3;
    spec=[];
    time=[];
    fileid=fopen(filename,'a');
    for i=1:size(a,2)
        for j=i+1:size(b,2)
            [Cxy,f] = mscohere(a{1,i},b{1,j},[],[],[],Fs);
          
            [pks,locs] = findpeaks(Cxy,'SortStr','descend','NPeaks',3);
            MatchingFreqs = f(locs);
%             [Cxy,f] = mscohere(ta{1,i},tb{1,j},[],[],[],Fs);
%             [pks,locs] = findpeaks(Cxy,'SortStr','descend','NPeaks',1);
            
            MatchingFreqs = [MatchingFreqs; f(locs)];
            MatchingFreqs=MatchingFreqs.';
            %whos MathchingFreqs
            spec=[spec;MatchingFreqs];

        end

    end
    %whos spec[pks,locs] = findpeaks(Cxy,'SortStr','descend','NPeaks',3);
    
    write_spec=unique(spec,'rows')
    %whos write_spec
    for k=1:size(write_spec,1)
        fprintf(fileid,'%f,%f,%f,%d\n',write_spec(k,1),write_spec(k,2),write_spec(k,3),code);
    end
    exit();
    fclose(fileid);
end

function measure_3Freq3Amp(a,filename,code)
    Fs=1e3;
    spec=[];
    global numofpeaks;
%     fileid=fopen(filename,'a');
    for i=1:size(a,2)
%         Fs = FsSig;
        [P1,f] = periodogram(a{1,i},[],[],Fs,'power');
%         [pk1,lc1] = findpeaks(P1,'SortStr','descend','NPeaks',3);
%         P1peakFreqs = f1(lc1);
%         spec=[spec;P1peakFreqs];
        
        [pks,locs] = findpeaks(P1,'SortStr','descend','NPeaks',numofpeaks);
        p=f(locs).';
        pks=pks.';
        if length(p)<numofpeaks
            u=repelem([0], numofpeaks-length(p));
            
            p=[p,u];
            pks=[pks,u];
%             diff = abs([p(1)-p(2), 0]);            
%         elseif length(p)==1
% %             diff = [0,0];
%             p=[p,0,0]; 
%             pks=[pks,0,0];
        end
        diff=[];
        for i=2:numofpeaks
            diff=[diff, p(i)-p(i-1)];
%         diff=[p(1)-p(2) for i in range()];
        end
        MatchingFreqs = [reshape(p,1,numofpeaks),reshape(pks,1,numofpeaks),reshape(diff,1,numofpeaks-1), code];
        spec=[spec;MatchingFreqs];
    end
    %whos spec
    write_spec=unique(spec,'rows');
    %whos write_spec
%     writematrix(write_spec, filename);
    dlmwrite(filename,write_spec,'-append');
%     for k=1:size(write_spec,1)
%         fprintf(fileid,'%f,%f,%f,%f,%f,%f,%f,%f,%d\n',write_spec(k,1),write_spec(k,2),write_spec(k,3),write_spec(k,4),write_spec(k,5),write_spec(k,6),write_spec(k,7),write_spec(k,8),code);
%     end
    
%     fclose(fileid);
end
function measure_peakFreq(a,filename,code)
    Fs=1e3;
    spec=[];
    fileid=fopen(filename,'a');
    for i=1:size(a,2)
%         Fs = FsSig;
        [P1,f1] = periodogram(a{1,i},[],[],Fs,'power');
        [pk1,lc1] = findpeaks(P1,'SortStr','descend','NPeaks',1);
        P1peakFreqs = f1(lc1);
        spec=[spec;P1peakFreqs];
    end
    %whos spec
    write_spec=unique(spec,'rows');
    %whos write_spec
    for k=1:size(write_spec,1)
        fprintf(fileid,'%f,%d\n',write_spec(k,1), code);
    end

    fclose(fileid);
end

