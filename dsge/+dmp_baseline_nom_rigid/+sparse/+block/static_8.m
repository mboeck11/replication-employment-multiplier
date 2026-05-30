function [y, T, residual, g1] = static_8(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=(y(25))-((1-params(10))*y(12)-y(10)-y(14)+y(25)*y(15)*(1-y(30)-y(20)));
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1-y(15)*(1-y(30)-y(20));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
