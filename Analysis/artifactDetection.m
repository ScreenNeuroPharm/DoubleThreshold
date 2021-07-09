function [artifact] =  artifactDetection(StimProtocol)

d = diff(StimProtocol);
artifact = find(d);
