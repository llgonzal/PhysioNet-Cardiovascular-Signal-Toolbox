function idxRRtoBeRemoved = FindSpikesInRR(RR, th, N)
%
% idxRRtoBeRemoved = FidnSpikesInRR(RR, th)
%
% OVERVIEW : Code used to clean RR intervals that change more than a given
% threshold (eg., th = 0.2 = 20%) with respect to the median value of the
% pervious N and next N RR intervals (using a forward-backward approach).
%
% INPUTS:
%        RR : a single row of rr interval data in seconds
%        th : threshold percent limit of change from one interval to the next
% OUTPUTS:
%        idxRRtoBeRemoved : a single vector of indexes related to RR
%                           intervals corresponding to a change > th
%
%   DEPENDENCIES & LIBRARIES:
%       PhysioNet Cardiovascular Signal Toolbox
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%
%   REFERENCE:
%   Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular
%   Waveform and Interval Analysis" Physiological Measurement (In Press), 2018.
%
%	REPO:
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%
%   Written by Giulia Da Poian (giulia.dap@gmail.com), 09-13-2017
%
%   LICENSE:
%       This software is offered freely and without warranty under
%       the GNU (v3 or later) public license. See license file for
%       more information
%
% changing it so the number of consecutive beats can be something other
% than 5.
passes=30;

if size(RR,1)>size(RR,2)
    RR = RR';
end
shift = round(N/2);

    function FiveRR_MedianVal = getFiveRRforward(currRR)
        % Forward search
        FiveRR_MedianVal = medfilt1(currRR,N); % compute as median RR(-i-2: i+2)
        % shift of three position to aligne with to corresponding RR
        FiveRR_MedianVal = [currRR(1:N) FiveRR_MedianVal(shift:end-shift)];
        
        lenrr = length(currRR);
        if lenrr<length(FiveRR_MedianVal)
            FiveRR_MedianVal = FiveRR_MedianVal(1:lenrr);
        end
        
    end

FiveRR_MedianVal = getFiveRRforward(RR);

rr_above_th = find((abs(RR-FiveRR_MedianVal)./FiveRR_MedianVal)>=th);
allrm_idxforward = rr_above_th;
for passnum = 1:passes
    RR_forward = RR;
    RR_forward(rr_above_th) = NaN;
    allrm_idxforward = unique([allrm_idxforward, rr_above_th]);
    RR_forward(rr_above_th) = FiveRR_MedianVal(rr_above_th);
    
    FiveRR_MedianVal = getFiveRRforward(RR_forward);
    
    rr_above_th = find((abs(RR_forward-FiveRR_MedianVal)./FiveRR_MedianVal)>=th);
    
end

% Backward search
RRfilpped = fliplr(RR);
% RRfilpped = fliplr(RR_forward);

FiveRR_MedianVal = medfilt1(RRfilpped,N); % compute as median RR(-i-2: i+2)
% FiveRR_MedianVal = medfilt1(RRfilpped,N,'omitnan'); % compute as median RR(-i-2: i+2)

% shift of three position to aligne with to corresponding RR
lenrr = length(RR);

FiveRR_MedianVal = [RRfilpped(1:N) FiveRR_MedianVal(shift:end-shift)];
if lenrr<length(FiveRR_MedianVal)
    FiveRR_MedianVal = FiveRR_MedianVal(1:lenrr);
end
rr_above_th = find(abs(RRfilpped-FiveRR_MedianVal)./FiveRR_MedianVal>=th);

allrm_idxback = rr_above_th;
for passnum = 1:passes
    rr_above_th = sort(length(RR)-rr_above_th+1);
    allrm_idxback = unique([allrm_idxback, rr_above_th]);
    
    RR_backward = RRfilpped;
    %     RR_backward(rr_above_th) = NaN;
    
    RR_backward(rr_above_th) = FiveRR_MedianVal(rr_above_th);
    
    rr_above_th = find(abs(RR_backward-FiveRR_MedianVal)./FiveRR_MedianVal>=th);
end
allrm_idxback = unique([allrm_idxback, rr_above_th]);


% Combine

% idxRRtoBeRemoved = (isnan(RR_forward) & isnan(RR_backward));
idxRRtoBeRemoved = zeros(length(RR),1);
tempidx = intersect(allrm_idxback, allrm_idxforward);
idxRRtoBeRemoved(tempidx) = 1;

end


