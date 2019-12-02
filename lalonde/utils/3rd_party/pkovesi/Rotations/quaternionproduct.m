% QUATERNIONPRODUCT - Computes product of two quaternions
%
% Usage: Q = quaternionproduct(A, B)
%
% Arguments: A, B - Quaternions assumed to be 4-vectors in the
%                   form  A = [Aw Ai Aj Ak]
% Returns:   Q    - Quaternion product
%
% See also: NEWQUATERNION, QUATERNIONROTATE, QUATERNIONCONJUGATE

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function Q = quaternionproduct(A, B)

    Q = zeros(4,1);    
    Q(1)  =  A(1)*B(1)  -  A(2)*B(2)  -  A(3)*B(3)  -  A(4)*B(4);
    Q(2)  =  A(1)*B(2)  +  A(2)*B(1)  +  A(3)*B(4)  -  A(4)*B(3);
    Q(3)  =  A(1)*B(3)  -  A(2)*B(4)  +  A(3)*B(1)  +  A(4)*B(2);
    Q(4)  =  A(1)*B(4)  +  A(2)*B(3)  -  A(3)*B(2)  +  A(4)*B(1);
