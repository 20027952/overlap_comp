#!/usr/bin/ksh
#选择C(7,3)的最小结果集,去覆盖C(7,2)
#
prt_comb()
{
    cn=$1
    cm=$2
    echo "to print comb $cm/$cn ..."
    echo ""|awk -v cn=$cn -v cm=$cm '{
        for(i=1;i<=cn;i++){            
            if(i<=cm){arr[i]=1;}
            else      {arr[i]=0;}
        }        
        for(j=1;j<=cn;j++){
            printf("%d",arr[j]);
            if(j==cn) {print ""}
        }        
        while(1){
            #从右往左扫描，找第一个10的结构，则把这个1右移一位；并把它右边的所有1，都移动来靠近它（在它的右边）。                
            delete right_1_pos;
            right_1_cnt=0;
            swap_cnt=0
            for(i=cn-1;i>=1;i--){
                if(arr[i+1]==1){right_1_pos[i+1]=1;right_1_cnt++;}
                if(arr[i]==1 && arr[i+1]==0){
                    swap_cnt++;
                    arr[i]=0
                    arr[i+1]=1;
                    for(k in right_1_pos)                          { arr[k]=0;}   
                    for(j=i+2;j<=cn && j<i+2+right_1_cnt;j++){ arr[j]=1;}  
                                    
                    for(j=1;j<=cn;j++){
                        printf("%d",arr[j]);
                        if(j==cn) {print ""}
                    }  
                    break ;               
                }
            }
            if(swap_cnt==0){break;}   #没有需要置换的，表示结束了
        }
    }'  
    
}

prt_comb 7 3
prt_comb 7 2
