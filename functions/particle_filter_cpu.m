function [filter_X, filter_weight, filter_X_mean] = particle_filter(N, dT, DR, beta_est, q_qnorm_est, rho_est, X_0_est)
  %時点がdT-1で終わることに注意(観測値に対して、使用するXが一期前であるため)
  filter_X = ones(dT - 1, N );
  filter_weight = ones(dT - 1, N);
  filter_X_mean = ones(dT - 1,1);
  for dt = 1:(dT - 1)
      if dt == 1
           %初期分布から　時点0と考えて
           pred_X = sqrt(beta_est)*X_0_est + sqrt(1 - beta_est) * random('Normal',0,1, N,1);
           %重みの計算
           weight = g_DR_dinamic(DR(2), pred_X, q_qnorm_est, beta_est, rho_est);
      else
           pred_X = sqrt(beta_est)*prior_X + sqrt(1 - beta_est) * random('Normal',0,1, N,1); 
           weight = g_DR_dinamic(DR(dt + 1), pred_X, q_qnorm_est, beta_est, rho_est) .* prior_weight;
      end
      
      %weightの正規化 一部の計算は並列計算できないからしょうがない
      cs_weight = cumsum(weight);
      weight = weight / cs_weight(N);
      cs_weight = cs_weight / cs_weight(N);
      resample_check_weight = weight.^2;
      resample_check_weight = sum(resample_check_weight);
      %リサンプリング (resample)とりあえず並列にしない
      if 1 / resample_check_weight < N / 10;
      dt;
      weight = repmat(1 / N, N, 1);
      resumple_num =  resample(cs_weight,rand(1,N) ,N);
      pred_X = pred_X(resumple_num);
      end
      
      filter_X(dt,:) = pred_X;
      prior_X = pred_X;
      filter_weight(dt,:) = weight;
      prior_weight = weight;
      filter_X_mean(dt) =  pred_X' * weight;
      %state_X_mean = (pred_X .* weight)(1,1);
  end
    
   
end