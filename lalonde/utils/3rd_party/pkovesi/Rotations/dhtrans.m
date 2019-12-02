% DHTRANS - computes Denavit Hartenberg matrix
%
% This function calculates the 4x4 homogeneous transformation matrix, representing
% the Denavit Hartenberg matrix, given link parameters of joint angle, length, joint
% offset and twist.
%
% Usage: T = DHtrans(theta, offset, length, twist)
% 
% Arguments:  theta - joint angle (rotation about local z)
%            offset - offset (translation along z)
%            length - translation along link x axis
%             twist - rotation about link x axis
%
% Returns:        T - 4x4 Homogeneous transformation matrix
%
% See also: TRANS, ROTX, ROTY, ROTZ, INVHT

% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function T = dhtrans(theta, offset, length, twist)

T = [ cos(theta) -sin(theta)*cos(twist)  sin(theta)*sin(twist) length*cos(theta)
      sin(theta)  cos(theta)*cos(twist) -cos(theta)*sin(twist) length*sin(theta)
          0             sin(twist)             cos(twist)         offset
          0                 0                      0                 1           ];