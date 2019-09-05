#! /usr/bin/env python3
# coding: utf-8

import pandas as pd
import numpy as np
from multiprocessing import Pool
from subprocess import call,check_output
import os,sys,shutil,argparse,subprocess

def print_logo():
    logo = '''
==================================================================
     \033[1;33m/\\\033[0m
    \033[1;33m/__\\\033[0m\033[1;31m\\\033[0m         This is a pipeline for statistical fine-mapping
   \033[1;33m/\033[0m  \033[1;31m---\\\033[0m        Author: Jianhua Wang
  \033[1;33m/\\\033[0m      \033[1;31m\\\033[0m       Date:   04-09-2019
 \033[1;33m/\033[0m\033[1;32m/\\\033[0m\033[1;33m\\\033[0m     \033[1;31m/\\\033[0m
 \033[1;32m/  \   /\033[0m\033[1;31m/__\\\033[0m
\033[1;32m`----`-----\033[0m
==================================================================
    '''
    print(logo)

def parseArguments():
    parser = argparse.ArgumentParser(usage="Finemap using three tools, output variants in total credible sets",description="python fine_map_pipe.py -s 120575 SUM_STAT ./",)
    parser.add_argument('input', type=str, help='input summary statistics'),
    parser.add_argument('output', type=str, help='directory of output file, default:working directory',default='./'),
    parser.add_argument('-p','--pop', type=str, choices=['EUR','EAS','SAS','AMR','AFR'], help='population of input data,[EUR,EAS,SAS,AMR,AFR], default=EUR',default='EUR',metavar=''),
    parser.add_argument('-n','--maxcausal', type=int, help='the maximum number of allowed causal SNPs, default=1',default=1,metavar=''),
    parser.add_argument('-s','--samplesize', type=int, help='sample size of input data',metavar='')
    parser.add_argument('-c','--cred', type=float, help='the cutoff of credible set, default=0.95',default=0.95,metavar='')
    parser.add_argument('-t','--thread', type=int, help='number of threads, default=10',default=10,metavar='')
    args = parser.parse_args()
    return args

def extract_overlap_and_cal_ld(pop,chr_id, start, stop):
	out_prefix = '{}/{}_{}_{}_{}'.format(out_dir,prefix,chr_id,start,stop)
	raw = pd.read_csv('{}.txt'.format(out_prefix),sep='\t')
	ref = pd.read_csv('{}/{}/{}_{}_{}_{}.txt.gz'.format(reference_dir,pop,pop,chr_id,start,stop),sep='\t')

	ref['snp'] = ref['CHROM'].astype(str)+':'+ref['POS'].astype(str)+':'+ref['REF']+':'+ref['ALT']
	raw['positive'] = raw['CHR'].astype(str)+':'+raw['BP'].astype(str)+':'+raw['NEA']+':'+raw['EA']
	raw['negative'] = raw['CHR'].astype(str)+':'+raw['BP'].astype(str)+':'+raw['EA']+':'+raw['NEA']

	negative = raw.merge(ref,left_on='negative',right_on='snp',how='inner')
	positive = raw.merge(ref,left_on='positive',right_on='snp',how='inner')

	negative['Zscore'] = -negative['Zscore']

	processed = pd.concat([positive,negative])

	if pd.isnull(processed.iloc[0,3]):
		processed['MAF'] = processed['{}_MAF'.format(pop)]
	processed['rsID'] = processed['ID']
	processed = processed.drop_duplicates('rsID')
	processed = processed.sort_values('BP')
	processed['coding'] = 1
	processed[['CHR', 'BP', 'rsID','MAF', 'EA', 'NEA', 'BETA', 'SE', 'P', 'Zscore','index']].to_csv('{}.processed'.format(out_prefix),sep=' ',index=False)
	paintor = processed[['CHR', 'BP', 'rsID','MAF', 'EA', 'NEA', 'BETA', 'SE', 'P', 'Zscore','index']]
	# paintor['PAINTOR'] = -1
	# paintor.to_csv('{}.processed.results'.format(out_prefix),sep=' ',index=False)
	finemap_z = processed[['rsID','CHR', 'BP','EA', 'NEA','MAF', 'BETA', 'SE']]
	finemap_z.columns = ['rsid', 'chromosome', 'position', 'allele1', 'allele2', 'maf', 'beta', 'se']
	finemap_z.to_csv('{}.processed.z'.format(out_prefix),sep=' ',index=False)
	processed[['rsID','Zscore',]].to_csv('{}.processed.caviarbf'.format(out_prefix),sep=' ',index=False,header=False)
	processed['coding'].to_csv('{}.processed.annotations'.format(out_prefix),sep=' ',index=False,header=True)
	np.savetxt('{}.processed.ld'.format(out_prefix), np.corrcoef(processed.iloc[:,18:-2].values), fmt='%1.4e')

def run_block(chr_id, start, stop):
    out_prefix = '{}/{}_{}_{}_{}.processed'.format(out_dir,prefix,chr_id,start,stop)
    prefix_name = '{}_{}_{}_{}.processed'.format(prefix,chr_id,start,stop)
    FNULL = open(os.devnull, 'w')
    # PAINTOR
    call('echo "{}" > {}.input'.format(prefix_name,out_prefix),shell=True)
    call('{} -input {}.input -out {} -Zhead Zscore -LDname ld -enumerate {} -in {}'.format(paintor,out_prefix,out_dir,max_causal,out_dir),shell=True, stdout=FNULL, stderr=subprocess.STDOUT)

    # CAVIARBF
    n_variants = check_output('wc -l {}.caviarbf'.format(out_prefix),shell=True).decode().split()[0]
    call('{} -z {}.caviarbf -r {}.ld -t 0 -a 0.1281429 -n {} -c {} -o {}.caviarbf.out'.format(caviarbf,out_prefix,out_prefix,sample_size,max_causal,out_prefix),shell=True, stdout=FNULL, stderr=subprocess.STDOUT)
    call('{} -i {}.caviarbf.out -m {} -p 0 -o {}.prior0'.format(model_search,out_prefix,n_variants,out_prefix),shell=True, stdout=FNULL, stderr=subprocess.STDOUT)

    # FINEMAP
    call('echo "z;ld;snp;config;cred;log;n_samples\n{}.z;{}.ld;{}.snp;{}.config;{}.cred;{}.log;{}" > {}.master'.format(out_prefix,out_prefix,out_prefix,out_prefix,out_prefix,out_prefix,sample_size,out_prefix),shell=True)
    call('{} --sss --in-files {}.master --n-causal-snps {}'.format(finemap,out_prefix,max_causal),shell=True, stdout=FNULL, stderr=subprocess.STDOUT)

def merge_results(chr_id, start, stop):
	out_prefix = '{}/{}_{}_{}_{}.processed'.format(out_dir,prefix,chr_id,start,stop)
	paintor = pd.read_csv('{}.results'.format(out_prefix),sep=' ',)
	paintor.columns = ['CHR', 'BP', 'rsID', 'MAF', 'EA', 'NEA', 'BETA', 'SE', 'P', 'Zscore','index', 'PAINTOR']
	caviarbf = pd.read_csv('{}.prior0.marginal'.format(out_prefix),sep=' ',names=['No','caviarbf']).sort_values('No')
	finemap = pd.read_csv('{}.config'.format(out_prefix),sep=' ',usecols=['config','prob'],index_col='config')

	merge = paintor.copy()
	merge['CAVIARBF'] = merge['PAINTOR']
	merge['FINEMAP'] = merge['PAINTOR']
	merge['CAVIARBF'] = caviarbf['caviarbf'].values
	merge['FINEMAP'] = [finemap.loc[rs,'prob'] for rs in merge['rsID']]
	merge['LD'] = check_output('head -n {} {}.ld | tail -n 1'.format(merge['P'].idxmin()+1,out_prefix),shell=True).decode().split()
	merge.index = merge['index']
	# merge.to_csv('{}.causal'.format(out_prefix),sep=' ',index=False)

	block = pd.read_csv('{}/{}_{}_{}_{}.txt'.format(out_dir,prefix,chr_id,start,stop),sep='\t')
	block['PAINTOR'] = -1
	block['CAVIARBF'] = -1
	block['FINEMAP'] = -1
	block['LD'] = -1
	block.index = block['index']
	block.update(merge.drop_duplicates('index'))
	block = block.astype({'CHR':int,'BP':int})
	block.to_csv('{}/{}_{}_{}_{}.causal.txt'.format(out_dir,prefix,chr_id,start,stop),sep='\t',index=False,header=False)

def get_credible_set(meta_id):
    sig_blocks = pd.read_csv(f'./{meta_id}/{meta_id}_significant_blocks.txt',sep='\t')
    block = pd.read_csv('./ref/blocks.txt',sep='\t')
    new_sig_blocks = pd.DataFrame(columns=[
        'chr', 'start', 'stop', 'count', 'missing', 'pa_n',
        'pa_p_min', 'pa_p_median', 'pa_pp_mean', 'pa_pp_median', 'ca_n',
        'ca_p_min', 'ca_p_median', 'ca_pp_mean', 'ca_pp_median', 'fi_n',
        'fi_p_min', 'fi_p_median', 'fi_pp_mean', 'fi_pp_median'
    ])
    total_credible = pd.Series()

    for i in sig_blocks.index:
        chr_id, start, stop = sig_blocks.loc[i]

        names = [
            'CHR', 'BP', 'rsID', 'MAF', 'EA', 'NEA', 'BETA', 'SE', 'P',
            'Zscore', 'index', 'PAINTOR', 'CAVIARBF', 'FINEMAP', 'LD'
        ]
        df = pd.read_csv(f'./{meta_id}/{meta_id}_{chr_id}_{start}_{stop}.causal.txt',sep='\t',names=names)

        credible_cutoff = args.cred
        maxpostprob_idx = pd.Series()
        fm_tool_cred = pd.Series(index=['PAINTOR', 'CAVIARBF', 'FINEMAP'],data=[[], [], []])
        fm_tool_label = pd.Series(index=['PAINTOR', 'CAVIARBF', 'FINEMAP'],data=[1, 2, 4])
        credible_set = df[df['FINEMAP'] != -1]
        for fm_tool in fm_tool_label.index:
            postprob = 0
            for idx in credible_set.sort_values(fm_tool,ascending=False).index:
                if df.loc[idx,'P']>5e-5:
#                     print(df.loc[idx,'P'])
                    break
                postprob += credible_set.loc[idx, fm_tool]
                fm_tool_cred[fm_tool].append(idx)
                if idx not in maxpostprob_idx:
                    maxpostprob_idx.loc[idx] = fm_tool_label[fm_tool]
                else:
                    maxpostprob_idx.loc[idx] += fm_tool_label[fm_tool]
                if postprob >= credible_cutoff:
                    break

        credible_set = df.loc[maxpostprob_idx.index]
        del credible_set['index']
        del credible_set['LD']
#         credible_set['meta_id'] = meta_id
#         credible_set['rsID'] = [x[2:] for x in credible_set['rsID']]
        credible_set['block_id'] = block[block['start'] == start].index[0] + 1
        credible_set['label'] = maxpostprob_idx

        new_sig_blocks.loc[i] = [
            chr_id,
            start,
            stop,
            len(df),
            len(df[df['LD'] == -1]),
            len(fm_tool_cred['PAINTOR']),
            credible_set.loc[fm_tool_cred['PAINTOR']]['P'].min(),
            credible_set.loc[fm_tool_cred['PAINTOR']]['P'].median(),
            credible_set.loc[fm_tool_cred['PAINTOR']]['PAINTOR'].median(),
            credible_set.loc[fm_tool_cred['PAINTOR']]['PAINTOR'].mean(),
            len(fm_tool_cred['CAVIARBF']),
            credible_set.loc[fm_tool_cred['CAVIARBF']]['P'].min(),
            credible_set.loc[fm_tool_cred['CAVIARBF']]['P'].median(),
            credible_set.loc[fm_tool_cred['CAVIARBF']]['CAVIARBF'].median(),
            credible_set.loc[fm_tool_cred['CAVIARBF']]['CAVIARBF'].mean(),
            len(fm_tool_cred['FINEMAP']),
            credible_set.loc[fm_tool_cred['FINEMAP']]['P'].min(),
            credible_set.loc[fm_tool_cred['FINEMAP']]['P'].median(),
            credible_set.loc[fm_tool_cred['FINEMAP']]['FINEMAP'].median(),
            credible_set.loc[fm_tool_cred['FINEMAP']]['FINEMAP'].mean(),
        ]

        total_credible.loc[i] = credible_set

    total_credible = pd.concat(total_credible.values)
#     total_credible['rsID'] = pd.to_numeric(total_credible['rsID'],
#                                            errors='coerce')
    total_credible.dropna().to_csv(f'{args.output}/{meta_id}_total_credible_set.txt',sep='\t',index=False)
    # new_sig_blocks.to_csv(f'./{meta_id}/{meta_id}_new_significant_blocks.txt',sep='\t',index=False)
#     print(meta_id)

if __name__ == "__main__":
    print_logo()
    args = parseArguments()
    
    paintor = './bin/PAINTOR_V3.0-3.0/PAINTOR'
    caviarbf = './bin/Wenan-caviarbf-7e428645be5e/caviarbf'
    model_search = './bin/Wenan-caviarbf-7e428645be5e/model_search'
    finemap = './bin/finemap_v1.3.1_x86_64/finemap_v1.3.1_x86_64'

    blocks_file = './ref/blocks.txt'
    reference_dir = './ref/ld/txt'

    blocks = pd.read_csv(blocks_file, sep='\t')
    threads = args.thread
    max_causal = args.maxcausal
    sample_size = args.samplesize

    # read input file
    input_file = args.input
    pop = args.pop
    pwd = os.getcwd()
    prefix = input_file.split('/')[-1].split('.')[0]
    out_dir = '{}/{}'.format(pwd,prefix)
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)
    print('loading input file')
    df = pd.read_csv(input_file, sep='\t')
    df = df.dropna(subset=['CHR','BP','EA','NEA','BETA','SE','P','Zscore'])
    if pd.isnull(df.iloc[0,3]):
        pass
    else:
        df = df[(df['MAF']>0) & (df['MAF']<=0.5)]
    df['index'] = df.index
    df = df[df['P']>0]
    significant_df = df[df['P']<=5e-8]

    if len(significant_df) == 0:
        significant_df = df[df['P'].idxmin():df['P'].idxmin()+1]

    # split files
    print('split files')
    significant_blocks = []
    for chr_id in range(1,23):
        df_chr = df[df['CHR']==chr_id]
        significant_chr = significant_df[significant_df['CHR']==chr_id]
        block_chr = blocks[blocks['chr']==chr_id]
        for significant_bp in significant_chr['BP']:
            for i in block_chr.index:
                if block_chr.loc[i,'start']<=significant_bp<=block_chr.loc[i,'stop']:
                    if i not in significant_blocks:
                        significant_blocks.append(i)
                        start,stop = block_chr.loc[i,'start'],block_chr.loc[i,'stop']
                        df_chr[(df_chr['BP']>=start) & (df_chr['BP']<=stop)].to_csv('{}/{}_{}_{}_{}.txt'.format(out_dir,prefix,chr_id,start,stop), sep='\t',index=False)
    significant_blocks = blocks.loc[significant_blocks]

    # prepare input files of finemapping tools
    print('prepare input files of finemapping tools')
    p = Pool(threads)
    for i in significant_blocks.index:
        chr_id, start, stop = significant_blocks.loc[i].values
        p.apply_async(extract_overlap_and_cal_ld,(pop,chr_id, start, stop))
    p.close()
    p.join()

    # run finemapping tools
    print('run finemapping tools')
    p = Pool(threads)
    for i in significant_blocks.index:
        chr_id, start, stop = significant_blocks.loc[i].values
        p.apply_async(run_block,(chr_id, start, stop))
    p.close()
    p.join()

    # gather results from three tools
    print('gather results')
    p = Pool(threads)
    for i in significant_blocks.index:
        chr_id, start, stop = significant_blocks.loc[i].values
        p.apply_async(merge_results,(chr_id, start, stop))
    p.close()
    p.join()

    # remove intermediate files
    # for file in os.listdir(out_dir):
    #     if file.endswith('.causal.txt'):
    #         pass
    #     else:
    #         os.remove(out_dir +'/'+ file)

    significant_blocks.to_csv('{}/{}/{}_significant_blocks.txt'.format(pwd,prefix,prefix),sep='\t',index=False)
    get_credible_set(prefix)
    shutil.rmtree(out_dir)

    # # debug
    # chr_id, start, stop = significant_blocks.iloc[0].values
    # extract_overlap_and_cal_ld(pop,chr_id, start, stop)
    # run_block(chr_id, start, stop)
    # merge_results(chr_id, start, stop)