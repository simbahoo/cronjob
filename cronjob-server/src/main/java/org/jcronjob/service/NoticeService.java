/**
 * Copyright 2016 benjobs
 * <p/>
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


package org.jcronjob.service;

import freemarker.template.Configuration;
import freemarker.template.Template;
import org.apache.commons.mail.HtmlEmail;
import org.jcronjob.base.utils.DateUtils;
import org.jcronjob.base.utils.HttpUtils;
import org.jcronjob.domain.Config;
import org.jcronjob.domain.Log;
import org.jcronjob.domain.User;
import org.jcronjob.domain.Worker;
import org.jcronjob.vo.JobVo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.*;
import java.util.*;

import static org.jcronjob.base.utils.CommonUtils.notEmpty;

/**
 * Created by benjobs on 16/3/18.
 */
@Service
public class NoticeService {

    private Config config;

    @Autowired
    private ConfigService configService;

    @Autowired
    private HomeService homeService;

    @Autowired
    private UserService userService;

    private Template template;

    private Logger logger = LoggerFactory.getLogger(getClass());

    @PostConstruct
    public void initConfig() throws Exception {
        this.config = configService.getSysConfig();
        Configuration configuration = new Configuration();
        File file = new File(getClass().getClassLoader().getResource("/").getPath().replace("classes","common"));
        configuration.setDirectoryForTemplateLoading(file);
        configuration.setDefaultEncoding("UTF-8");
        this.template = configuration.getTemplate("email.template");
    }

    public void updateConfig(Config newConfig){
        this.config = newConfig;
    }

    public void notice(Worker worker) {
        if (!worker.getWarning()) return;
        String content = getMessage(worker, "通信失败,请速速处理!");
        logger.info(content);
        try {
            sendMessage(null,worker.getWorkerId(), worker.getEmailAddress(), worker.getMobiles(), content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void notice(JobVo job) {
        Worker worker = job.getWorker();
        String message = "执行任务:" + job.getCommand() + "(" + job.getCronExp() + ")失败,请速速处理!";
        String content = getMessage(worker, message);
        logger.info(content);
        try {
            sendMessage(job.getOperateId(),worker.getWorkerId(), worker.getEmailAddress(), worker.getMobiles(), content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getMessage(Worker worker, String message) {
        String msgFormat = "[cronjob] 机器:%s(%s:%s)%s\n\r\t\t--%s";
        return String.format(msgFormat, worker.getName(), worker.getIp(), worker.getPort(), message, DateUtils.formatFullDate(new Date()));
    }

    public void sendMessage(Long receiverId,Long workId, String emailAddress, String mobiles, String content) {
        try {
            HtmlEmail email = new HtmlEmail();
            email.setCharset("UTF-8");
            email.setHostName(config.getSmtpHost());
            email.setSslSmtpPort(config.getSmtpPort().toString());
            email.setAuthentication(config.getSenderEmail(), config.getPassword());
            email.setFrom(config.getSenderEmail());
            email.setSubject("cronjob监控告警");
            email.setHtmlMsg(msgToHtml(receiverId,content));
            email.addTo(emailAddress.split(","));
            email.send();

            Log log = new Log();
            log.setType(0);
            log.setWorkerId(workId);
            log.setMessage(content);
            for (String receiver : emailAddress.split(",")) {
                log.setReceiver(receiver);
                log.setSendTime(new Date());
                homeService.saveLog(log);
            }
            log.setType(1);
            for (String mobile : mobiles.split(",")) {
                //发送POST请求
                String sendUrl = String.format(config.getSendUrl(), mobile, String.format(config.getTemplate(), content));

                String url = sendUrl.substring(0, sendUrl.indexOf("?"));
                String postData = sendUrl.substring(sendUrl.indexOf("?") + 1);

                String message = HttpUtils.doPost(url, postData, "UTF-8");
                log.setReceiver(mobile);
                log.setResult(message);
                log.setSendTime(new Date());
                homeService.saveLog(log);
                logger.info(message);

            }
        } catch (Exception e) {
            e.printStackTrace(System.err);
        }

    }

    private String msgToHtml(Long receiverId,String content) throws Exception {
        Map root = new HashMap();
        if (receiverId!=null) {
            User user = userService.getUserById(receiverId);
            root.put("receiver", notEmpty(user) ? user.getRealName() : "管理员");
        }else {
            root.put("receiver","管理员");
        }
        root.put("message", content);
        StringWriter writer = new StringWriter();
        template.process(root, writer);
        return writer.toString();
    }

}
