#!/usr/bin/env python
# coding: utf-8

# In[2]:
import numpy as np
import torch
from transformers import ElectraTokenizer
from torch.utils.data import Dataset, DataLoader
import torch.nn.functional as F
from transformers import  ElectraModel
from torch import nn


class Text_Input(Dataset):
    
    def __init__(self, data):
        self.data = data
        self.tokenizer =  ElectraTokenizer.from_pretrained("monologg/koelectra-small-v3-discriminator")


    def __len__(self):
        return len(self.data)

    def __getitem__(self,idx):
        text = self.data
        inputs = self.tokenizer(
            text,
            return_tensors='pt',
            truncation=True,
            max_length=512,
            padding='max_length',
            add_special_tokens=True
            )

        input_ids = inputs['input_ids'][0]
        attention_mask = inputs['attention_mask'][0]
        return input_ids, attention_mask

class ElectraForMultiClassClassification(nn.Module):
    def __init__(self, num_classes):
        super(ElectraForMultiClassClassification, self).__init__()
        self.electra = ElectraModel.from_pretrained("monologg/koelectra-small-v3-discriminator")
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(self.electra.config.hidden_size, num_classes)

    def forward(self, input_ids, attention_mask):
        outputs = self.electra(input_ids=input_ids, attention_mask=attention_mask)
        pooled_output = outputs.last_hidden_state[:, 0]  # [CLS] 토큰의 표현
        pooled_output = self.dropout(pooled_output)
        logits = self.classifier(pooled_output)
        return logits 

def getTextOutputs(user_input_text):
    text_input = Text_Input(user_input_text)
    device =  torch.device("cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu")
    text_loader = DataLoader(text_input, batch_size=1, shuffle=True)
    num_classes = 7  # 클래스 개수에 맞게 설정
    
    

    # 저장된 모델
    model = torch.load('./model/7th_koElectraModel.pt',map_location=device)
    model.eval()

    # DataLoader에서 배치 가져오기 및 모델에 입력
    for input_ids_batch, attention_masks_batch in text_loader:
        input_ids_batch = input_ids_batch.to(device)
        attention_masks_batch = attention_masks_batch.to(device)
        with torch.no_grad():  # 추론 모드에서 gradient 계산을 하지 않음
            # 모델에서 얻은 로짓(logits) 값
            outputs = model(input_ids=input_ids_batch, attention_mask=attention_masks_batch)
        
            # 소프트맥스 함수 적용하여 확률 계산
    prob = F.softmax(outputs, dim=1).cpu().numpy() #내가 도출해야 할 값은 이거
    prob_mean = prob.mean(axis=0)

    
    return prob_mean
#     return prob


