function [y, T] = dynamic_1(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(81)=(1-params(37))*params(12)+params(37)*y(37)+x(1)*params(42);
  y(48)=(1-params(37))*params(20)+params(37)*y(4)+x(1)*params(41);
  y(78)=y(48)+0.95*y(34);
  y(87)=log(y(48));
end
