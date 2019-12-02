function out=labFinv(in)

out = (in.^3).*(in>.2069) + ((in-16/116)/7.787).*(in<=.2069);
