function [y, T] = static_9(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(40)=log(y(5));
  y(38)=log(y(1));
  y(36)=y(12)/y(35);
  y(26)=y(24)+y(25)/(1-params(10));
end
