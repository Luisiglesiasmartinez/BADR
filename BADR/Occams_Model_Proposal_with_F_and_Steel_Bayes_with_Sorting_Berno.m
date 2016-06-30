function  [Averaged_Models, Adjacency_Matrix, Edges_Inhibition_Activation]= Occams_Model_Proposal_with_F_and_Steel_Bayes_with_Sorting_Berno(mRNA_to, dmRNA_dt, Candidates, Prior)

%% Preprocessing

No_of_Genes = size(mRNA_to,2);
Genes = 1:No_of_Genes;

n = size(dmRNA_dt, 1);
Mean_Response = mean(dmRNA_dt);
Mean_Response = repmat(Mean_Response, size(dmRNA_dt, 1), 1);
Var = sum((dmRNA_dt - Mean_Response).^2);
% Change is here
No_of_TFs = size(Candidates,2);
Averaged_Models = zeros(No_of_Genes);
Sum_of_Bayes_Factors = zeros(No_of_Genes,1);
Adjacency_Matrix = Averaged_Models;
Edges_Inhibition_Activation = zeros(No_of_Genes,No_of_Genes+1);

%% Estimate Degrees of Freedom

Degrees_of_Freedom = size(mRNA_to,1);

%%
for j = 1: size(dmRNA_dt,2)
    
            mu_dmRNA_dt = mean(dmRNA_dt(:,j));
               %% Step 1: Calculate the "Null" model's Bayes Factor
                
                Design_Matrix = [ mRNA_to(:,j) ones(size(mRNA_to,1),1)];
                
                
                bs = pinv(Design_Matrix'*Design_Matrix)*Design_Matrix'*dmRNA_dt(:,j);
                
                % Calculate Sum of Squared Errors
                
                %%SSE = (dmRNA_dt(:,j)'*dmRNA_dt(:,j) - dmRNA_dt(:,j)'*mRNA_to(:,j)*pinv(mRNA_to(:,j)'*mRNA_to(:,j))*mRNA_to(:,j)'*dmRNA_dt(:,j));
                %%SSE = (dmRNA_dt(:,j)'*dmRNA_dt(:,j) - dmRNA_dt(:,j)'*Design_Matrix*bs);
                                                    
                %% Change is here!
                
                gs = 1/n;
                
                D_M_2 = mRNA_to(:,j);
                bs_2 = pinv(D_M_2'*D_M_2)*D_M_2'*dmRNA_dt(:,j);
                V = (D_M_2*bs_2-dmRNA_dt(:,j)-mu_dmRNA_dt);
                V = V'*V;
                
               
                U = gs/(gs+1)*((D_M_2*bs_2)'*D_M_2*bs_2);
                
                
                
                %Bayes_Factor_Null = (gs/(gs+1))^1/2*(1/(gs+1)*SSE+gs/(gs+1)*Var(j))^(-(n-1)/2);
                Bayes_Factor_Null = (gs/(gs+1))^1/2*((V+U)/2)^(-(n-1)/2);
                
                Prior_Null = prod(1-Prior(j,Candidates));
                
                BF_Root = Bayes_Factor_Null*Prior_Null;
                
                Root = 0;
               
                Active = 1;
               
              
                                      while Active 
                      %% Step 2: Add the Next Gene in the List
                                          if Root == 0;
                                          
                                              New_Roots = zeros(No_of_TFs,1);
                                              Sorted_TFs = New_Roots;
                                         
                                            
                                          else
                                              
                                              New_Roots = zeros(No_of_TFs,size(Root,2)+1);
                                          
                                            
                                          end
                                      counter = 0;
                                      Top_BF = 0;
                                      
                                      for l = 1: size(Root,1)
                                      
                                      I=find(Candidates(j,:)==Root(l,end));
                                          if Root(l,:) == 0;
                                          Branches = Candidates(j,:);
                                          else
                                          Branches = Candidates(j,I+1:end);
                                          end
                                      
                                    
                                      
                                                  for k = 1:length(Branches)
                                        
                                                      if Root(l,:) == 0
                                                      
                                                      D_M = [mRNA_to(:, Branches(k)) mRNA_to(:,j) ones(size(mRNA_to,1),1)];
                                                       D_M_2 = [mRNA_to(:, Branches(k)) mRNA_to(:,j)];
                                                      p = size(D_M,2)-1;
                                                      
                                                      else 
                                                          
                                                          D_M = [mRNA_to(:,[Root(l,:) Branches(k)]) mRNA_to(:,j)  ones(size(mRNA_to,1),1)];
                                                           D_M_2 = [mRNA_to(:,[Root(l,:) Branches(k)]) mRNA_to(:,j)];
                                                      p = size(D_M,2)-1;
                                                      
                                                      end
                                                      
                                                      bs = pinv(D_M'*D_M)*D_M'*dmRNA_dt(:,j);
                                                      bs_2 = pinv(D_M_2'*D_M_2)*D_M_2'*dmRNA_dt(:,j);
                                                      
                                                      %% Calculate Sum of Squared Errors
                                                      
                                                      Model = D_M*bs;

                                                      
                                                      SSE = (dmRNA_dt(:,j)'*dmRNA_dt(:,j) - dmRNA_dt(:,j)'*Model);
                                                      SSE = (dmRNA_dt(:,j)'*dmRNA_dt(:,j) - dmRNA_dt(:,j)'*D_M_2*bs_2);
                                                     
                                                      V = (D_M_2*bs_2-dmRNA_dt(:,j)-mu_dmRNA_dt);
                                                        V = V'*V;
                
                                                  U = gs/(gs+1)*((D_M_2*bs_2)'*D_M_2*bs_2);
                
                
             
                                                      
                                                      
                                                      %% Evaluate Bayes Factor
                                                      
                                                     
                                                       
                                                     
                                                       if p^2<=n
                                                         
                                                          gs = 1/n;
                                                       else
                                                          
                                                           gs = (p/n)^(1/2);
                                                       end
                                                       
                                                       %% Calculate Model Probability
                                                       
                                                       Not_Included = zeros(No_of_Genes,1);
                                                        
                                                       
                                                       Not_Included(Candidates) = 1;
                                                       
                                                       Not_Included(Branches(k)) = 0;
                                                       
                                                       Not_Included = find(Not_Included>0);
                                                       
                                                       %Not_Included = setdiff(Candidates, Branches(k));
                                                        
                                                       Variable_Probability = [Prior(j,Branches(k)) (1-Prior(j,Not_Included))];
                                                       
                                                       
                                                       Model_Probability = prod(Variable_Probability)*(p-1)^-2.66;
                                                       
                                                       if j == 4
                                                       
                                                       
                                                      % BF = (gs/(gs+1))^((p)/2)*(1/(gs+1)*SSE+gs/(gs+1)*Var(j))^(-(n-1)/2)*Model_Probability;
                                                       BF = (gs/(gs+1))^((p)/2)*((U+V)/2)^(-(n-1)/2)*Model_Probability;
                                                       end
                                                      
                                                        %   BF = (gs/(gs+1))^((p)/2)*(1/(gs+1)*SSE+gs/(gs+1)*Var(j))^(-(n-1)/2)*Model_Probability;
                                                      BF = (gs/(gs+1))^((p)/2)*((U+V)/2)^(-(n-1)/2)*Model_Probability;
                                                      
                                                      %% Step 4: Store models which are good performers

                                                            if BF>BF_Root
                                                                counter = counter +1;
                                                              if Root(l,:) ==0
                                                              
                                                              
                                                              New_Roots(counter) = Branches(k);
                                                             
                                                              
                                                              else
                                                              New_Roots(counter,:) = [Root(l,:) Branches(k)];
                                                              
                                                              end
                                                              
                                                              if Top_BF<BF
                                                              Top_BF = BF;
                                                              end
                                                              
                                                             
                                                              Vector = zeros(1,No_of_Genes);
                                                              Coefficients = zeros(1,No_of_Genes+1);
                                                                if Root(l,:) ==0
                                                                Vector( Branches(k)) = 1;
                                                                Coefficients(Branches(k)) = bs(1)*(1+gs);
                                                                Coefficients(j) = bs(2)*(1+gs);
                                                                Coefficients(end) = bs(end)*(1+gs);
                                                                else
                                                               Vector([Root(l,:) Branches(k)]) = 1;
                                                               Coefficients([Root(l,:) Branches(k)])= bs(1:end-2)*(1+gs);
                                                               Coefficients(j) = bs(end-1)*(1+gs);
                                                               Coefficients(end) = bs(end)*(1+gs);
                                                                end
                                                              
                                                              
                                                              
                                                               
                                                              Averaged_Models(j,:) = Averaged_Models(j,:)+ Vector*BF;
                                                              Edges_Inhibition_Activation(j,:) = Edges_Inhibition_Activation(j,:) + Coefficients*BF;
                                                              Sum_of_Bayes_Factors(j) = Sum_of_Bayes_Factors(j) + BF;
                                                             
                                                              
                                                            end
                                                       
                                                    
                
                                                  end
                                      end
                                                  
                                              %%  Define the State of the search (if none models passed stop the search)
                                                             if  sum(New_Roots) == 0
                                                 
                                                                   Active = 0;
                                                            
                                                                    
                                                                 
                                                             else
                                                               if Root == 0
                                                                   
                                                                   Sorted_TFs(1:counter) = New_Roots(1:counter);
                                                                  
                                                                   Sorted_TFs(counter+1:end) = setdiff(Candidates(j,:), New_Roots(1:counter));
                                                                   
                                                                   Candidates(j,:) = Sorted_TFs;
                                                               end
                                                               
                                                                   Root = New_Roots(1:counter,:);
                                                                  
                                                                   BF_Root = Top_BF;
                                                  
                                                             end    
                                                             if size(Root,2)>Degrees_of_Freedom
                                                                 
                                                                 Active = 0;
                                                                 
                                                             end
                                             end
                                                 
                                          %% Step 7: Return the adjacency matrix
                                      if  Sum_of_Bayes_Factors(j)>0
                                      Adjacency_Matrix(j,:) = Averaged_Models(j,:)/Sum_of_Bayes_Factors(j);
                                      
                                      Edges_Inhibition_Activation(j,:) = Edges_Inhibition_Activation(j,:)/Sum_of_Bayes_Factors(j); 
                                      end
                                      end
                                      
             
               
                
                

end