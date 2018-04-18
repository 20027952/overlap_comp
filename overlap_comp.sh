#!/usr/bin/ksh
#选择C(9,3)的最小结果集，它的每一个"3数组合"包括6个“2数组合”,可以覆盖C(9,2)。
#C(9,3)有84个“3数组合”
#C(9,2)有36个“2数组合”
#现在要找出最少的“3数组合”集（每个“3数组合”可包含3个“2数组合”），可以覆盖C(9,2)的所有36个“2数组合”
#36/3=12个“3数组合”

#组合的打印方法：
#C(N,M),制作一个N列数，其中左边M个为1，其它为0。尝试把1往右为0的位置移动，移动后，它右边的所有1，都向它靠拢，进行下一次移动。

#选择C(9,3)的方法，从其中选择一个数，把它包括的3个组合，放到集合A中。并删除C（9，2）的结果集。
#选择C(9,3)的第二个数，如果它的3个组合有任一个在集合A中，则放弃这个数，找下一个。
#这样循环。
#最后打印C(9,2)的剩下的数。


prt_comb()
{
    cn=$1
    cm=$2
    echo "to print comb $cm/$cn ..."
    file=comb.$cn.$cm.unl
    echo ""|awk -v cn=$cn -v cm=$cm -v file="$file" '{        
        for(i=1;i<=cn;i++){            
            if(i<=cm){arr[i]=1;}
            else      {arr[i]=0;}
        }        
        
        swap_cnt=1   
        all_swap_cnt=0    
        do{            
            if(swap_cnt==0){
                print "total:"all_swap_cnt+1;                
                break;
            }   #没有需要置换的，表示结束了
            
            for(j=1;j<=cn;j++){
                printf("%d",arr[j]) > file;
                if(j==cn) {print "" > file;}
            } 
        
            #从右往左扫描，找第一个10的结构，则把这个1右移一位；并把它右边的所有1，都移动来靠近它（在它的右边）。                
            delete right_1_pos;
            right_1_cnt=0;
            swap_cnt=0
            for(i=cn-1;i>=1;i--){                
                if(arr[i+1]==1){right_1_pos[i+1]=1;right_1_cnt++;}
                if(arr[i]==1 && arr[i+1]==0){
                    swap_cnt++;
                    all_swap_cnt++;
                    arr[i]=0
                    arr[i+1]=1;
                    for(k in right_1_pos) { arr[k]=0;}   
                    for(j=i+2;j<=cn && j<i+2+right_1_cnt;j++){ arr[j]=1;}                                                        
                    break ;               
                }
            }
            
        }while(1)
    }' 
    ls -al $file
    echo ""
}

#前两个集合从文件读取
select_comb()
{
    cn1=$1  #eg. 9
    cm1=$2  #eg. 2
    cm2=$3  #eg. 3
    echo "to select comb $cn1,$cm1,$cm2 ..."
    
    prt_comb $cn1 $cm1  #c(9,2)
    prt_comb $cm2 $cm1  #c(3,2)
    file1=comb.$cn1.$cm1.unl
    file2=comb.$cm2.$cm1.unl    

echo ""|awk -v cn1=$cn1 -v cm1=$cm1 -v cm2=$cm2 -v file1=$file1 -v file2=$file2 'BEGIN{
        while(getline line<file1){arr1[line]=1;arr1_cnt++;}
        while(getline line<file2){arr2[line]=1;arr2_cnt++;}
    }{           
        cm=cm2
        cn=cn1
        for(i=1;i<=cn;i++){
            if(i<=cm){arr[i]=1;}
            else      {arr[i]=0;}
        }        
                                
        all_swap_cnt=0
        swap_cnt=1    #第一个数认为有移动
        do{    
            if(swap_cnt==0){break;}#没有需要置换的，表示结束了
                                
            #得到当前一个组合的3个C（9，2）
            #生成的一个数，其中标识值为1的3个位置，进行C（3，2）的组合，对应的位置，反映成3个C（9，2）
            delete pos_arr;
            pos_cnt=0;
            for(j=1;j<=cn;j++){
                if(j==1){val="";val_pos="";}                        
                val=sprintf("%s%d",val,arr[j]);
                if(arr[j]==1){
                    val_pos=sprintf("%s %d",val_pos,j);
                }
                if(arr[j]==1){
                    pos_cnt++;
                    pos_arr[pos_cnt]=j;
                    #print j;
                }                        
                if(j==cn){
                    #print val;
                    repeat_new_c92_cnt=0;
                    delete new_c92;
                    for(key in arr2){
                        split(key,arrtmp,"");
                        for(k=1;k<=cm2;k++){
                            if(k==1){delete arrval;}
                            if(arrtmp[k]==1){                                         
                                arrval[pos_arr[k]]=1 
                            }
                        }
                        for(k=1;k<=cn1;k++){
                            if(k==1){val2=""}
                            val2=sprintf("%s%d",val2,arrval[k]);
                            if(k==cn1){
                                #print val2;       #一个c(9,2)值  ,如果它已经发现，则这个数不输出
                                if(val2 in already_found_c92){
                                    repeat_new_c92_cnt++;
                                    #print "                             skip:"val,val2;
                                    #break;
                                }
                                new_c92[val2]=1;
                            }
                        }
                    }
                    #重复率，它的3个c（9，2）基本是新的，则要选择这个组合 。
                    if( repeat_new_c92_cnt/arr2_cnt==0){                        
                        #print "ok:"val;
                        print val_pos;
                        select_cnt++;
                        all_repeat_new_c92_cnt+=repeat_new_c92_cnt;
                        for(key in new_c92){
                            delete arr1[key];   #如果已经被覆盖，则删除这个集合中的key值
                            already_found_c92[key]=1;
                            #print "    new:"key;
                        }
                    }      
                }
            }                                         
            
            #移动产生新数
            delete right_1_pos;
            right_1_cnt=0;
            swap_cnt=0
            for(i=cn-1;i>=1;i--){
                if(arr[i+1]==1){right_1_pos[i+1]=1;right_1_cnt++;}
                if(arr[i]==1 && arr[i+1]==0){
                    swap_cnt++;
                    all_swap_cnt++;
                    arr[i]=0
                    arr[i+1]=1;
                    for(k in right_1_pos)                    { arr[k]=0;}   
                    for(j=i+2;j<=cn && j<i+2+right_1_cnt;j++){ arr[j]=1;}                                          
                    break ;               
                }
            }            
            
        }while(1)
        #print all_swap_cnt+1;
        
        for(key in arr1){
            #printf("not overlap :%s\n",key);
            not_overlap++;
        }
        printf("best select:%d,select_cnt:%d/%d,not_overlap:%d/%d,repeat:%d\n",arr1_cnt/arr2_cnt,select_cnt,all_swap_cnt+1,not_overlap,arr1_cnt,all_repeat_new_c92_cnt);
    }'    
}
#select_comb 7 2 3
#select_comb 15 2 3
#select_comb 31 2 3
#select_comb 30 2 3
select_comb 9 2 3
