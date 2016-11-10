#!/usr/bin/python2.7

import numpy as np
import pylab as pl
import os

SHANKS = [0,1,2,3,4]

def print_channels (root,CLUSTER):
  a = np.load(root+'/templates.npy')
  NUM_CHAN = a.shape[2]
  b = np.load(root+'/channel_positions.npy')
  if 0>1:
    for i in range(0,NUM_CHAN):
      print 'min',a[CLUSTER,:,i].min(),' max',a[CLUSTER,:,i].max(),' channel',i,' location ',b[i]
  
  templates_for_cluster_0 = a[CLUSTER,:,:]
  # ndarray of min value for each of NUM_CHAN templates for cluster 0
  min_cluster_0 = templates_for_cluster_0.min(axis=0)
  # add index to get two column array
  c = np.vstack((range(0,NUM_CHAN),min_cluster_0)).T
  # sort by 2nd column = min template value
  c_sorted = c[c[:,1].argsort()]
  
  for i in range(0,NUM_CHAN):
    if c_sorted[i,1]<-1.5e-2:
      print 'channel',c_sorted[i,0],' min_value',c_sorted[i,1],' location',b[c_sorted[i,0]]

def print_spikes (root,CLUSTER):
  a = np.load(root+'/spike_templates.npy')
  # get indices in a that match CLUSTER
  i = np.where(a==CLUSTER)
  foo = np.count_nonzero(a == CLUSTER)
  #print 'cluster',CLUSTER+1,'num spikes',foo
  b = np.load(root+'/spike_times.npy')
  # matching spikes in units of sample index. To convert to times, divide by sample rate (30000).
  st = b[i[0]]
  print st
  #print 'cluster',CLUSTER+1,'num spikes',foo,'num times',len(st)


################
for SHANK in SHANKS:

  root = '/home/jkinney/Desktop/60secs_automerge/awake_gratings_and_grass_offset_133200014_count_1800000/GPU/shank%d' % SHANK
  
  print '\nshank = ',SHANK
  if os.path.isfile(root+'/spike_clusters.npy') == True:
    print 'File spike_clusters.npy is found.'
    spike_clusters = np.load(root+'/spike_clusters.npy')
  else:
    print 'File spike_clusters.npy is not found. Using spike_templates.npy instead.'
    spike_clusters = np.load(root+'/spike_templates.npy')
  
  print 'Number of spikes =',len(spike_clusters),'\n\n'
  
  clusters = np.unique(spike_clusters)
  cluster_size = {}
  for cluster in clusters:
    cluster_size[cluster] = np.count_nonzero(spike_clusters == cluster)
    if cluster_size[cluster] > 500:
      print '\nshank',SHANK,'cluster',cluster,'num spikes',cluster_size[cluster]
      # first cluster always contains artifacts or whatever it is
      if cluster>0:
        print_channels(root,cluster-1) # for some reason cluster-1 yields correct index into templates.npy
        print_spikes(root,cluster-1)

