## ------------------------------------------------------------------------------------------
## Subjective and objective equality assessment for augmented reality images 
## Pengfei Wang, Huiyu Duan, Zongyi Xie, Xiongkuo Min, and Guangtao Zhai
## IEEE Open Journal on Immersive Displays
## Reference from ：
## Confusing image quality assessment: Towards better augmented reality experience
## Huiyu Duan, Xiongkuo Min, Yucheng Zhu, Guangtao Zhai, Xiaokang Yang, and Patrick Le Callet
## IEEE Transactions on Image Processing (TIP)
## ------------------------------------------------------------------------------------------
import torch.backends.cudnn as cudnn
cudnn.benchmark=False

import numpy as np
import os
import lpips
import argparse

import torch
from torch.autograd import Variable
from torchvision import transforms
import torch.backends.cudnn as cudnn

import dataset_cfiqa_ariqa

from calc_performance import IQAPerformance

import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('--net', type=str, default='alex', help='[squeeze], [alex], or [vgg] for network architectures')
parser.add_argument('--name', type=str, default='tmp', help='directory name for training')
parser.add_argument('--use_gpu', action='store_true', help='turn on flag to use GPU')
parser.add_argument('--gpu_ids', type=int, nargs='+', default=[0], help='gpus to use')
parser.add_argument('--save_folder', type=str, default='results/cfiqa_baseline', help='results directory')

parser.add_argument('--data_dir', dest='data_dir', help='Directory path for testing reference image data.',
        default='../../database', type=str)
parser.add_argument('--test_filename_list', dest='test_filename_list', help='Path to text file containing relative paths for every example.',
        default='./train_test_split/CFIQA/CFIQA_all.csv', type=str)


opt = parser.parse_args()
opt.save_dir = os.path.join(opt.save_folder,opt.name)
if(not os.path.exists(opt.save_dir)):
    os.makedirs(opt.save_dir)

import lpips.lpips_sal as lpips

net = lpips.LPIPS(net=opt.net)

if(opt.use_gpu):
    net.to(opt.gpu_ids[0])
    net = torch.nn.DataParallel(net, device_ids=opt.gpu_ids)

transformations = transforms.Compose([transforms.Resize(224),transforms.ToTensor(),transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])])
test_filename_list = opt.test_filename_list
CFIQA_dataset_test = dataset_cfiqa_ariqa.FRIQA_Dataset(opt.data_dir,test_filename_list,transformations, is_train=False)
test_loader = torch.utils.data.DataLoader(dataset=CFIQA_dataset_test,batch_size=1,shuffle=False,num_workers=0)

# testing
total_loss = 0
test_mos_predict = []
test_mos_origin = []

# switch to evaluate mode
# model.eval()


with torch.no_grad():
    for i, (img_dis, img_ref, mos) in enumerate(test_loader):
        print(i)
        img_dis = Variable(img_dis)
        img_ref = Variable(img_ref)
        # mos
        mos = mos[:,np.newaxis]
        mos = Variable(mos)
        dev = torch.device("cuda")
        img_dis.to(dev)
        img_ref.to(dev)
        mos.to(dev)
        # calculate predicted mos on testing set
        loss = net.forward(img_dis, img_ref)

        mos_predict = loss

        # append predicted mos and mos
        test_mos_predict.append(np.reshape(mos_predict.cpu().numpy(),(1)))
        test_mos_origin.append(np.reshape(mos.cpu().numpy(),(1)))

iqa = IQAPerformance(test_mos_origin,test_mos_predict)
print(iqa.compute())
print('----')

np.save(os.path.join(opt.save_dir,opt.net+'_baseline.npy'), test_mos_predict)
test_dataframe = []
for result in test_mos_predict:
    result = result[0]
    each_row = []
    each_row.append(result)
    test_dataframe.append(each_row)
df = pd.DataFrame(test_dataframe,columns = ['results'])
df.to_csv(os.path.join(opt.save_dir,opt.net+'_baseline.csv'),header=False,index=False)