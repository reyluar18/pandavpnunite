�
    �0�f�  �                   �P  � d dl Z d dlZd� Zd� Zd� Zd� Zd� Zedk(  �r} ej                  d�	�      Z	e	j                  d
dd��       e	j                  ddd��       e	j                  ddd��       e	j                  �       ZdZ edd�      5 Z eej#                  �       �      Zddd�       dZ ededz   �      D ]�  Zde� dej*                  � �Z ee�      r ede� d��       �*ej/                  d�      d    Z eej*                  dej0                  ej2                  e�      \  ZZerc ede�        ede� ��       dez   Ze� Z eej*                  deej2                  e�      \  ZZer ed e�        ed!e� ��       dZ n ed"�        n ed#�        n es e d$�      �yy# 1 sw Y   ��xY w)%�    Nc                 �<  � d}d|� �dd�}| dd�}t        j                  |||��      }|j                  dk(  r9|j                  �       j                  d	g �      }|r|d
   d   S t	        d| � ��       y t	        d|j                  � ��       t	        |j
                  �       y )Nz*https://api.cloudflare.com/client/v4/zones�Bearer �application/json��AuthorizationzContent-Type�active)�name�status��headers�params��   �resultr   �idz!No active zone found for domain: zFailed to fetch zone ID: ��requests�get�status_code�json�print�text)�domain_name�bearer_token�urlr   r   �response�zoness          �	source.py�get_zone_idr      s�   � �
6�C� #�<�.�1�*��G� ���F�
 �|�|�C���@�H����s�"�����#�#�H�b�1�����8�D�>�!��5�k�]�C�D���)�(�*>�*>�)?�@�A��h�m�m���    c                 �,  � d| � d�}d|� �dd�}||d�}t        j                  |||��      }|j                  dk(  r-|j                  �       j                  d	g �      }|r
d
|d   d   fS yt	        d|j                  � ��       t	        |j
                  �       y)N�+https://api.cloudflare.com/client/v4/zones/�/dns_recordsr   r   r   )�typer	   r   r   r   Tr   r   )FNzFailed to check DNS records: �NNr   )	�zone_id�record_type�record_namer   r   r   r   r   �recordss	            r   �dns_record_existsr)      s�   � �7��y��
M�C� #�<�.�1�*��G� ���F�
 �|�|�C���@�H����s�"��-�-�/�%�%�h��3�������D�)�)�)���-�h�.B�.B�-C�D�E��h�m�m��r   c                 �   � d| � d�}	 t        j                  |d��      }|j                  dk(  ryy# t         j                  $ r
}Y d }~yd }~ww xY w)Nzhttp://z:5623/server_info.txt�   )�timeoutr   TF)r   r   r   �RequestException)�cnamer   r   �es       r   �is_dns_aliver0   9   sS   � ��E�7�/�
0�C���<�<��Q�/�����3�&�����$�$� ����s   �&0 �A�Ac                 �h   � t        | d�      5 }|j                  |�       d d d �       y # 1 sw Y   y xY w)N�w)�open�write)�path�dns�files      r   �write_resultr8   D   s-   � �	�d�C�� �D��
�
�3��� � �s   �(�1c                 �2  � t        | |�      }|sy|� d| � �}t        ||||�      \  }}|r�d|� d|� �}	d|� �dd�}
|||dd	d
�}t        j                  |	|
|��      }|j                  dk(  rt        d|� d��       |dfS t        d|j                  � ��       t        |j                  �       yd|� d�}	d|� �dd�}
|||dd	d
�}t        j                  |	|
|��      }|j                  dk(  r|dfS t        d|j                  � ��       t        |j                  �       y)Nr$   �.r!   z/dns_records/r   r   r   �   F)r#   r	   �content�ttl�proxied)r   r   r   zDNS record z updated successfullyTzFailed to update DNS record: )NFr"   zFailed to create DNS record: )r   r)   r   �putr   r   r   �post)r   r&   �record_contentr   r'   r%   �full_record_name�record_exists�	record_idr   r   �datar   s                r   �create_dns_recordrF   H   s{  � � �+�|�4�G���%��a��}�5��  1��+�GW�Ye�f��M�9�� <�G�9�M�R[�Q\�]��&�|�n�5�.�
��
  �$�%���
�� �<�<��W�4�@�����3�&��K� 0�1�1F�G�H�#�T�)�)��1�(�2F�2F�1G�H�I��(�-�-� �� <�G�9�L�Q��&�|�n�5�.�
��
  �$�%���
�� �=�=��g�D�A�����3�&�#�T�)�)��1�(�2F�2F�1G�H�I��(�-�-� �r   �__main__z#Register DNS record with Cloudflare)�descriptionz--tokenzCloudflare API tokenT)�help�requiredz--namezDomain namez	--contentz5Content of the DNS record (IP address or name server)�
   z/root/dns_count.txt�rFr;   �serverr:   zDNS server z! is alive. Trying the next one...�Az/root/sub_domain.txtz
A Record: zns-�NSz/root/ns.txtzNS Record: zBError in creating/updating NS record... manual intervention neededzEError in creating/updating CNAME record... manual intervention neededz@Unable to create/update DNS records for any available DNS server)!r   �argparser   r)   r0   r8   rF   �__name__�ArgumentParser�parser�add_argument�
parse_args�args�dns_serversr3   �f�int�read�success�range�
dns_serverr	   r   �splitr<   �token�full_cname_record�is_cname_success�ns_record_name�ns_record_content�full_ns_record�is_ns_success�	Exception� r   r   �<module>rh      s  �� � ��6�4	��<�| �z��$�X�$�$�1V�W�F�
���	�(>���N�
����}�t��D�
����*a�lp��q�����D� �K�	�#�S�	)� $�Q��!�&�&�(�m��$� �G��A�{�1�}�-� �
��j�\��4�9�9�+�6�
��
�#��K�
�|�+L�M�N�#�)�)�#�.�q�1�J� 3D�D�I�I�s�TX�T`�T`�bf�bl�bl�nx�2y�/��/���3�5F�G��
�#4�"5�6�7� "'�z�!1��'8�&9�!�0A�$�)�)�T�Sd�fj�fp�fp�  sA�  1B�-��� � ���@��K��'7�8�9�"�G���^�_���]�^��=�@ ��Z�[�[� �] �$� $�s   �F�F%