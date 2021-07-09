function [varargout] = aVa_catData(varargin)
for jj = 1:nargin
    varargout{jj} = cell2mat(varargin{jj});
end
